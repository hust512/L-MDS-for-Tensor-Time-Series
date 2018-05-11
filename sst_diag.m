addpath('functions');
% data
load data/sst
N = numel(X);
Ntrain =1800;

% Setting the type of noise-----------------------------------------------

Type = struct('Q0','Diag','Q','Diag','R','Diag');
I = size(X{1});
J = [2 3];
M = numel(I);
Ntest = N - Ntrain;

%reexpressed tensors as vectors to fit LDS--------------------------------

X_vectorized = vec2ten(ten2vec(X), prod(I));

% LDS---------------------------------------------------------------------

disp('Fitting LDS...')
sizes = zeros(prod(I), 1);
for i = 1:prod(I)
  sizes(i) = number_of_parameters(prod(I), i,Type);
end
clear i
J_lds = find(sizes >= number_of_parameters(I, J,Type),1);
clear i sizes
model_lds = learn_mlds(subcell(X_vectorized, 1:Ntrain),Type, 'J',J_lds );
err_lds = err(X, Ntrain, model_lds);


%compute J----------------------------------------------------------------
for i = 1:I(1)
  sizes(i) = L_number_of_parameters(X,I(1), i,Type);
end
J_lmlds = find(sizes >= number_of_parameters(I, J,Type),1);
if isempty(J_lmlds)
    J_lmlds=I(1);
end
%dct-MLDS-----------------------------------------------------------------
[result,model_dct]= dct_mlds(X,J_lmlds,Ntrain,Type);
err_dct = Err_dct(X,result,Ntrain);

%dwt-MLDS-----------------------------------------------------------------

J_dwt=J_lmlds;
err_dwt = Err_dwt( X,J_dwt,Ntrain,Type);

%dft-MLDS-----------------------------------------------------------------

result1 = dft_mlds(X,J_lmlds,Ntrain,Type);
err_dft=Err_dct(X,result1,Ntrain);

% MLDS--------------------------------------------------------------------

disp('Fitting MLDS with matching number of parameters...')
J_mlds = prod(J);
model_mlds = learn_mlds(subcell(X, 1:Ntrain),Type, 'J', J);
err_mlds = err(X, Ntrain, model_mlds);



% plot results------------------------------------------------------------
disp('Plotting results...')
subplot(1,1,1);
hold on;
T = [1:Ntest]+Ntrain; 
plot(T, err_lds, 'Color', 'blue');
plot(T, err_mlds, 'Color', 'black');
plot(T, err_dft, 'Color', 'yellow');
plot(T, err_dct, 'Color', 'red');
plot(T, err_dwt, 'Color', 'green');
hold off;
legend('LDS','MLDS','dft-MLDS','dct-MLDS','dwt-MLDS');
xlim([1 Ntest] + Ntrain);
xlabel('Time slice');
ylabel('Error');
