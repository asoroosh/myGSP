

N = 100; 
nM = 4;
sM = N./nM;
M = MakeModularNetwork(N,nM,0.2);

Xclean = []; 
for i = 1:nM
    RndSign = ((rand>0.5)*2-1);
    Xclean = [Xclean;ones(sM,1).*i.*RndSign];
end

%Noise = rand(1,N);
Noise = 0;

X = Xclean + Noise';
%X = Xclean; 

L = myGSP_LapMat(M,'normalise');
Xh = myGSP_Smoothness(L,X)

figure; imagesc(M)