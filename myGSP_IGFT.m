function X = myGSP_IGFT(A,Xhat)

N = size(A,1);

if size(Xhat,1)~=N; error('X is not in the right format, perhaps transpose?'); end;
if size(A,1)~=size(A,2); error('A is not square! What are you on about?'); end; 

A(1:N+1:end) = 0;
L  = diag(sum(A))-A; 

[V0,U0] = eig(L); %can be changed to SVD
U0  = diag(U0); 

signs = sign(V0(1,:));
signs(signs==0) = 1;
V0 = V0*diag(signs);

X = V0*Xhat; % inverse GFT
end