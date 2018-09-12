function [Xhat] = myGSP_Smoothness(L,X)
% [Xhat,V0,U0,L,ZC] = myGSP_Smoothness(L,X)
% 
%%INPUT:
% L : Either the adjacency matrix (A) or the Laplacian matrix (L)
% X : signal on vertices (optional)
%
%%OUTPUT:
% Xhat : Graph Fourier transformed signal (if X is not fed, then it is gonna be empty)
% V0 : eig vectors
% U0 : eig values
% L  : Laplacian Mat
% ZC : Zero-crossings
%
%
% SA, Uni of Oxford, 2018
%

N = size(L,1);

if size(L,1)~=size(L,2); error('A is not square! What are you on about?'); end; 

%%% GFT ----
% L = myGSP_LapMat(A);
%%[V0,U0] = eig(L); %can be changed to SVD! hang on shouldn't be eig(L'L)?!
%[V0,U0] = svd(L);

%U0 = diag(U0);
%[U0,idx] = sort(U0,'ascend');
%V0 = V0(:,idx);

%signs = sign(V0(1,:));
%signs(signs==0) = 1;
%V0 = V0*diag(signs);

%count the zero crossings
% this should work too: sum(diff(sU0(:,i)>0)~=0)
% for i = 1:N 
%     ZC(i) = sum(abs(diff(sign(V0(:,i))))==2); 
% end

%%% GFT ----
X = X-mean(X')';
X = X./std(X')';

if size(X,1) ~= N
    X = X';
    warning('You are inputting X in a wrong settings.');  
end

T = size(X,2);

for i = 1:T
    Xhat(i) =X(:,i)'*L*X(:,i); %GFT
end

end