function [mVG,VG,Grad,TV] = myGSP_VertexGrad(L,X)
% [Xhat,V0,U0,L,ZC] = myGSP_Smoothness(L,X)
% 
%%INPUT:
% L : Either the adjacency matrix (A) or the Laplacian matrix (L)
% X : signal on vertices
%
%%OUTPUT:
% VG: Vertex gradients
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

%% Initialise
Smpl = 50;

%% Do the job!

for i = 1:L.N
    for j=1:L.N
        for t = 1:Smpl:T
            Grad(i,j,t) = L.W(i,j).*(X(i,t)-X(j,t)).^2; 
        end
    end 
end

VG  = squeeze(sum(Grad));
mVG = mean(VG,2);
TV  = (sum(Grad(:)))./2;

end