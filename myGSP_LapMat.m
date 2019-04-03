function [L,UV] = myGSP_LapMat(A,varargin)
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

A = full(A); 

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

disp('myGSP_LapMat:: Eigen decomposition...')


% If X is a NxN real symmetric matrix with non-negative eigenvalues, 
%then eigenvalues and singular values coincide, but it is not generally the case!
%
% gsp_compute_fourier_basis.m
% [V0,U0,~] = svd((LM+LM')/2); 

[V0,U0] = gsp_full_eigen(LM);

% In octave, you can either do [V0,U0,X0] or [S0]! So we have to have three
% outputs. But, for a symmetric matrix, I assume V0 is the eigenvectors and
% U0 is the eigenvalues.

% V0: eigenvectors 
% U0: eigenvalues

% U0 = diag(U0);
% [U0,idx] = sort(U0,'ascend');
% V0 = V0(:,idx);

% disp('--')
% size(idx)
% disp('--')

signs = sign(V0(1,:));
signs(signs==0) = 1;
V0 = V0*diag(signs);

if sum(strcmpi(varargin,'sparse'))
    disp('myGSP_LapMat:: The results will be in sparse matrices.')
	L.W = sparse(triu(A));
	L.L = sparse(LM); %Laplacian Matrix
else
	L.W = A;
    L.L = LM; %Laplacian Matrix
end
L.N = N;

UV.U = U0; %eigenvalues **THIS SHOULD BE COLUMN!**
UV.V = V0; %eigenvectors 
UV.N = N;

end

function [U,E] = gsp_full_eigen(L)
%GSP_FULL_EIGEN Compute and order the eigen decomposition of L

    % Compute and all eigenvalues and eigenvectors 
%     try
%         [eigenvectors,eigenvalues]=eig(full(L+L')/2);
%     catch
        [eigenvectors,eigenvalues,~]=svd(full(L+L')/2);
%     end
    % Sort eigenvectors and eigenvalues
    [E,inds] = sort(diag(eigenvalues),'ascend');
    eigenvectors=eigenvectors(:,inds);
    
    % Set first component of each eigenvector to be nonnegative
    signs=sign(eigenvectors(1,:));
    signs(signs==0)=1;
    U = eigenvectors*diag(signs);
end
