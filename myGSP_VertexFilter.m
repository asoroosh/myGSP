function Xf = myGSP_VertexFilter(UV,X,H)
%
%%% INPUTS:
%   L: Laplacian matrix
%   X: Signal, if empty then the signal is assumed to be weighted degrees
%      of each node
%   H: Transfer function. That is an identity matrix with targetted freqs 
%      set to zero.
%      Examples:
%               CutOff = 30; 
%               lpH = @(x) x.*[ones(CutOff,1);zeros(numel(x)-CutOff,1)];
%               hpH = @(x) x.*[zeros(numel(x)-CutOff,1);ones(CutOff,1)];
%
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

%% Read the time series %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if size(X,1) == UV.N
    T = size(X,2);
elseif size(X,2) == UV.N
    T = size(X,1); 
else
    error('length of the graph signal is wrong!')
end
X = reshape(X,[UV.N,T]);

%% Do the job!
% transform to the freq domain
Xhat = myGSP_GFT(UV,X);

% filter out in graph signal domain

%Xfhat = conj(H(UV.U))*Xhat;
Xfhat = conj(H(UV.U)).*Xhat;
% I have checked this with the GSPbox:
% 

% and, transform back to the vertex domain
Xf = myGSP_IGFT(UV,Xfhat);

% follow notations in Graph Frequency Analysis of Brain Signals, 
% Huang et al, 2016

end