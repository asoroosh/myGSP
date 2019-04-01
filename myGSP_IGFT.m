function X = myGSP_IGFT(L,Xhat)
%X = myGSP_IGFT(L,Xhat,varargin)
%
%%INPUT:
% L : Laplacian matrix, or the adjacency matrix 
% Xhat : signal in freq domain (\hat{x})
%
%%OUTPUT:
% X: signal in time domain
%
% Soroosh Afyouni, Uni of Oxford, 2018
%

% gsp_igft.m

%% Read the time series 
if size(Xhat,1) == L.N
    T = size(Xhat,2);
elseif size(Xhat,2) == L.N
    T = size(Xhat,1); 
else
    error('length of the graph signal is wrong!')
end
Xhat = reshape(Xhat,[L.N,T]);

%% Do the job

X = L.V*Xhat; % inverse GFT: Eq 4; x=V\hat{x} % inverse GFT

% follow notations in Graph Frequency Analysis of Brain Signals, 
% Huang et al, 2016

end