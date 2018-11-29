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
    
% What the fuck is this?! I can't remember how I arrived to this    
%     D(D~=0) = sqrt(1./D(D~=0));
%     D = spdiags(D,0,speye(size(A,1)));
%     A0 = D*A*D;
%     L0 = speye(size(A0,1))-A0; % L = I-D^-1/2 * W * D^-1/2

    idx = D>0;
    L = - A;
    % Ln = D^(-1/2) L D^(-1/2)
    L(idx,:) = bsxfun(@times, L(idx,:), 1./sqrt(D(idx)));
    L(:,idx) = bsxfun(@times, L(:,idx), 1./sqrt(D(idx))');
    % put back diagonal to identity
    % Note: for disconnected nodes we should still have 1 on diagonal
    % (limit of L for W -> 0)
    L(1:N+1:end) = 1;

else
    L  = diag(D)-A; 
end

end
    