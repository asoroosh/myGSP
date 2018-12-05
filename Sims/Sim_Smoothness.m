
clear

addpath(genpath('/Users/sorooshafyouni/Home/GSP/myGSP'))

N = 100; 
nM = 4;
sM = N./nM;
nRlz = 50; 
Noise=0; RndSign=1;

CutOff = 5;

%Remove everything BUT the last 20 components:
lpH = eye(N); 
lpH(1:N-CutOff,1:N-CutOff) = 0;

%just keep the first 20 components:
hpH = eye(N); 
hpH(CutOff:end,CutOff:end) = 0;

for itr = 1:1
    M = MakeModularNetwork(N,nM,0.1,'RichClub');
    M = M.*abs(rand(N)); %put positive weights 
    
    Xclean = []; 
    for i = 1:nM
        %RndSign = ((rand>0.5)*2-1);
        Xclean = [Xclean;ones(sM,1).*i.*RndSign];
    end

    
%%% Add the last block    
    %LastBlock = randi(5,[sM,1]).*((rand(sM,1)>0.5)*2-1); %high frequency
    %LastBlock = ones(sM,1).*(i+1).*RndSign; %low frequency
    
    %Xclean = [Xclean;LastBlock];
    
%     %the last block
%     RndSign = ((rand(sM)>0.5)*2-1);
%     Xclean = [Xclean;3.*RndSign];
    
    
    
    %Noise = randn(1,N);
    X = Xclean + Noise';
    
    myGSP_plot3D(M,X)
    
    %== Unfiltered
    L = myGSP_LapMat(M,'normalise');
    Xh(itr) = myGSP_Smoothness(L,X);
    
    %== LP filtered
    lpXf = myGSP_VertexFilter(L,X,lpH,'piecewise');
    lpXf_tmp = myGSP_Smoothness(L,lpXf);
    lpXh(itr) = lpXf_tmp;
    %== HP filtered
    hpXf = myGSP_VertexFilter(L,X,hpH,'piecewise');
    hpXf_tmp = myGSP_Smoothness(L,hpXf);
    hpXh(itr) = hpXf_tmp;
    
    clear *_tmp
end

disp(['all: ' num2str(mean(Xh)) ', l:' num2str(mean(lpXh)) ', h:' num2str(mean(hpXh))])
