function Topol = myGSP_RBF(DistMat,Sigma)

if ~exist('Sigma','var')
    idx   = find(triu(ones(size(DistMat,1)),1));
    Sigma = mean(DistMat(idx));
end

Gamma = 1./(2*(Sigma.^2));
Topol = exp(-(DistMat.^2)*Gamma);