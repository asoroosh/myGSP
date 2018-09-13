function Xf = myGSP_VertexFilter(L,X,H,mode)
%
%
% SA, Uni of Oxford, 2018
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