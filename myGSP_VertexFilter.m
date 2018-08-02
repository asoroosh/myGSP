function Xf = myGSP_VertexFilter(A,X,H)

N = size(A,1);

if isempty(X)
    disp('Signal hasnt been set, so we set it to strength of nodes.')
    X = sum(A)';
else
    if size(X,1)~=N 
        error('X is not in the right format, perhaps transpose?'); 
    end
end

if size(A,1)~=size(A,2) 
    error('A is not square! What are you on about?'); 
end 


[Xhat,~,U0] = myGSP_GFT(A,X);

Xfhat = H.*Xhat;

Xf = myGSP_IGFT(A,Xfhat);