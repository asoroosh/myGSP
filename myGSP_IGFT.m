function X = myGSP_IGFT(L,Xhat,varargin)
% L : Laplacian matrix, or the adjacency matrix 
% Xhat : signal in freq domain (\hat{x})
%
% SA, Uni of Oxford, 2018
%

N = size(L,1);
if size(Xhat,1)~=N; error('X is not in the right format, perhaps transpose?'); end;
if size(L,1)~=size(L,2); error('A is not square! What are you on about?'); end; 

T = size(Xhat,2);

[V0,U0] = svd(L); %can be changed to SVD
U0 = diag(U0);

[U0,idx] = sort(U0,'ascend');
V0 = V0(:, idx); 

signs = sign(V0(1,:));
signs(signs==0) = 1;
V0 = V0*diag(signs);

if sum(strcmpi(varargin,'piecewise'))
    for i = 1:T
        X(:,i) = V0*Xhat(:,i); %GFT
    end
else
    X = V0*Xhat; % inverse GFT
end

end