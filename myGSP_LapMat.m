function L = myGSP_LapMat(A,varargin)
% L = myGSP_LapMat(A,varargin)
% normalised and non-normalised Laplacian graphs
%
% A: adjacency matrix 
% L: laplacian matrix 
% trigger normalisation by 'normalise' in input
%
%
%
% SA, Uni of Oxford, 2018
%
N = size(A,1);

A(1:N+1:end) = 0;
D = sum(A,2);

if sum(strcmpi(varargin,'normalise'))
    D(D~=0) = sqrt(1./D(D~=0));
    D = spdiags(D,0,speye(size(A,1)));
    A = D*A*D;
    L = speye(size(A,1))-A; % L = I-D^-1/2*W*D^-1/2
else
    L  = diag(D)-A; 
end
    