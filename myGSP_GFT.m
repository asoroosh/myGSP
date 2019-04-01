function Xhat = myGSP_GFT(UV,X)
% Xhat = myGSP_GFT(A,X)
% 
%%INPUT:
% L : Either the adjacency matrix (A) or the Laplacian matrix (L)
% X : signal on vertices (optional)
% mode [optional]: If you wanna do the GFT on each time points of X, 
%                  then use 'piecewise'
%
%%OUTPUT:
% Xhat : Graph Fourier transformed signal (if X is not fed, then it is gonna be empty)
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com
%

% gsp_gft.m

%% Read the time series
if size(X,1) == UV.N
    T = size(X,2);
elseif size(X,2) == UV.N
    T = size(X,1); 
else
    error('length of the graph signal is wrong!')
end
X = reshape(X,[UV.N,T]);

%% Do the job!

Xhat = UV.V'*X; % inverse GFT: Eq 3; \hat{x}=V^{H}x % GFT

%follow notations in Graph Frequency Analysis of Brain Signals, 
% Huang et al, 2016
       
end