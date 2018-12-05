function Xf = myGSP_VertexFilter(L,X,H,mode)
%
%%% INPUTS:
%   L: Laplacian matrix
%   X: Signal, if empty then the signal is assumed to be weighted degrees
%      of each node
%   H: Transfer function. That is an identity matrix with targetted freqs 
%      set to zero.
%   mode [optional]: if 'piecewise' is used, then the oprations (GFT and 
%                    filtering is done on each time point.) 
%
%%% OUTPUTS:
%   Xf: filtered signals
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com
%

% See gsp_filter_analysis.m of gspbox
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4; mode = ''; end;

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
% transform to the freq domain
Xhat = myGSP_GFT(L,X,mode);

% filter out in graph signal domain
Xfhat = conj(H(L.U)).*Xhat;

% and, transform back to the vertex domain
Xf = myGSP_IGFT(L,Xfhat,mode);

% follow notations in Graph Frequency Analysis of Brain Signals, 
% Huang et al, 2016

end