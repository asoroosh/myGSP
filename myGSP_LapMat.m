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
    disp('myGSP_LapMat:: Normalised laplacian')
    idx = D>0;
    LM = - A;
    LM(idx,:) = bsxfun(@times, LM(idx,:), 1./sqrt(D(idx)));
    LM(:,idx) = bsxfun(@times, LM(:,idx), 1./sqrt(D(idx))');
    LM(1:N+1:end) = 1;
    L.LMType = 'normalised'; 
else
    disp('myGSP_LapMat:: Non-normalised laplacian')
    LM  = diag(D)-A; 
    L.LMType = 'non-normalised'; 
end

% gsp_compute_fourier_basis.m
[V0,U0] = svd((LM+LM')/2);

% disp('--')
% size(V0)
% size(U0)
% disp('--')

% V0: eigenvectors 
% U0: eigenvalues

U0 = diag(U0);
[U0,idx] = sort(U0,'ascend');
V0 = V0(:,idx);

% disp('--')
% size(idx)
% disp('--')

signs = sign(V0(1,:));
signs(signs==0) = 1;
V0 = V0*diag(signs);

L.W = A;
L.N = N;
L.L = LM; %Laplacian Matrix
L.U = U0; %eigenvalues **THIS SHOULD BE COLUMN!**
L.V = V0; %eigenvectors 

end
