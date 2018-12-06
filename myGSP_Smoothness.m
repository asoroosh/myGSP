
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

% for sanity check:
% for i = 1:100; for j=1:100; 
% Grad(i,j) = A(i,j).*(X(i)-X(j)).^2; 
% end; end;
% (sum(Grad(:)))./2
% this should result in an identical number as TV

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