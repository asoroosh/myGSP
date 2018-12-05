
function [TV] = myGSP_Smoothness(L,X)
% [Xhat,V0,U0,L,ZC] = myGSP_Smoothness(L,X)
% 
%%INPUT:
% L : Either the adjacency matrix (A) or the Laplacian matrix (L)
% X : signal on vertices
%
%%OUTPUT:
% TV: smoothness / total variation respective to the topology
%
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com
%

%% Read the time series 
if size(X,1) == L.N
    T = size(X,2);
elseif size(X,2) == L.N
    T = size(X,1); 
else
    error('length of the graph signal is wrong!')
end
X = reshape(X,[L.N,T]);

%% Do the job!
for i = 1:T
    TV(i) =X(:,i)'*L.L*X(:,i); %GFT
end

end