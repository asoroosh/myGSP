function L = myGSP_LapMat(A)

N = size(A,1);

A(1:N+1:end) = 0;
L  = diag(sum(A))-A; 