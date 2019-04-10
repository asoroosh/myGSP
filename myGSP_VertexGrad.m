function [mVG,VG,Grad,TV] = myGSP_VertexGrad(L,X,varargin)
% [Xhat,V0,U0,L,ZC] = myGSP_Smoothness(L,X)
% 
%%INPUT:
% L : Either the adjacency matrix (A) or the Laplacian matrix (L)
% X : signal on vertices
%
%%OUTPUT:
% VG: Vertex gradients
%
%%REFERENCES:
% Ortega 2018, Shuman 2013
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com
%

%% Read the Network
if isstruct(L)
    %disp('Input is a structure!')
    N = L.N;
    W = L.W;
else
    %disp('Input is a matrix!')
    N = size(L,1); 
    W = L;
end

%% Read the time series
if size(X,1) == N
    T = size(X,2);
elseif size(X,2) == N
    T = size(X,1); 
else
    error('length of the graph signal is wrong!')
end
X = reshape(X,[N,T]);

%% Do the job!
Grad = zeros(N);
if sum(strcmpi(varargin,'correlation'))
    %disp(['In corr land'])
    for i = 1:N
        for j=1:N
            if W(i,j) && i<j
                % Grad(i,j) = W(i,j).*2.*(1-corr(X(i,:)',X(j,:)')); 
                % The line above was the original; but where this 2 comes
                % from?! And also, what is gonna happen to the negative
                % correlations? So added a .^2 just in case.
                Grad(i,j) = W(i,j)*(1-corr(X(i,:)',X(j,:)').^2); 
            end
        end 
    end
    Grad = Grad + Grad';
else 
    for i = 1:N
        for j=1:N
            if W(i,j) && i<j
            	Grad(i,j) = W(i,j).*mean((X(j,:)-X(i,:)).^2); 
            end
        end 
    end
    Grad = Grad + Grad';
end


TV  = sum(sum(Grad))./2;

VG  = squeeze(sum(triu(Grad,1)));
mVG = mean(VG,2); % across time

end