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
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com
%
N = size(L,1);

if ~exist(mode,'var') 
    mode = ''; 
end; 

if isempty(X)
    disp('Signal hasnt been set, so we set it to strength of nodes.')
    X = sum(L)';
else
    if size(X,1)~=N 
        error('X is not in the right format, perhaps transpose?'); 
    end
end

if size(L,1)~=size(L,2) 
    error('A is not square! What are you on about?'); 
end 


% transform to the freq domain
Xhat = myGSP_GFT(L,X,mode);

% filter out in graph signal domain
Xfhat = H*Xhat;

% and, transform back to the vertex domain
Xf = myGSP_IGFT(L,Xfhat,mode);