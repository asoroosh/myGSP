function [Xhat,sV0,sU0,idx,U0,V0] = myGSP_GFT(A,X)

N = size(A,1);

if size(A,1)~=size(A,2); error('A is not square! What are you on about?'); end; 

A(1:N+1:end) = 0;
L  = diag(sum(A))-A; 

[V0,U0] = eig(L); %can be changed to SVD
%[V0,U0] = svd(L);

U0 = diag(U0);
[sU0,idx] = sort(U0,'ascend');
sV0=V0(:,idx);

signs = sign(V0(1,:));
signs(signs==0) = 1;
V0 = V0*diag(signs);

if nargin==1
    Xhat = [];
else
    if size(X,1)~=N; error('X is not in the right format, perhaps transpose?'); end;
    Xhat = V0'*X; %GFT
end

end