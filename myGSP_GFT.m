function [Xhat,V0,U0,ZC] = myGSP_GFT(L,X,varargin)
% [Xhat,V0,U0,L,ZC] = myGSP_GFT(A,X)
% 
%%INPUT:
% L : Either the adjacency matrix (A) or the Laplacian matrix (L)
% X : signal on vertices (optional)
% mode [optional]: If you wanna do the GFT on each time points of X, 
%                  then use 'piecewise'
%
%%OUTPUT:
% Xhat : Graph Fourier transformed signal (if X is not fed, then it is gonna be empty)
% V0 : eig vectors
% U0 : eig values
% L  : Laplacian Mat
% ZC : Zero-crossings
%
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com
%

N = size(L,1);

if size(L,1)~=size(L,2); error('A is not square! What are you on about?'); end; 

% L = myGSP_LapMat(A);

%[V0,U0] = eig(L); %can be changed to SVD! hang on shouldn't be eig(L'L)?!
[V0,U0] = svd(L);

U0 = diag(U0);
[U0,idx] = sort(U0,'ascend');
V0 = V0(:,idx);

signs = sign(V0(1,:));
signs(signs==0) = 1;
V0 = V0*diag(signs);

%count the zero crossings
% this should work too: sum(diff(sU0(:,i)>0)~=0)
% for i = 1:N 
%     ZC(i) = sum(abs(diff(sign(V0(:,i))))==2); 
% end

if nargin==1
    Xhat = [];
else
    if size(X,1)~=N; error('X is not in the right format, perhaps transpose?'); end;
    
    T = size(X,2);
    X = X-mean(X')';
    X = X./std(X')';
    
    if sum(strcmpi(varargin,'piecewise'))
        for i = 1:T
            Xhat(:,i) = V0'*X(:,i); %GFT
        end
    else
        Xhat = V0'*X; %GFT
    end
        
end

end