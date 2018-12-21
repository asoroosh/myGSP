
clear

addpath(genpath('/Users/sorooshafyouni/Home/GSP/myGSP'))

N = 5; 
HowMany = 5;
%sM = N./nM;
nRlz  = 1; 
Noise = 0; 

%Remove everything BUT the last 20 components:
CutOff = 1; 
lpH = @(x) x.*[ones(CutOff,1);zeros(numel(x)-CutOff,1)];
bpH = @(x) x.*[zeros(CutOff,1);ones(numel(x)-2.*CutOff,1);zeros(CutOff,1)];
hpH = @(x) x.*[zeros(numel(x)-CutOff,1);ones(CutOff,1)];


Nds = [0 0 0];
while true
        Nds = randi(N,1,HowMany);
        if numel(unique(Nds))==HowMany
            break;
        end
end

M = zeros(N);
for i = 1:HowMany
    for j = 1:HowMany
        if Nds(i)==Nds(j); continue; end; 
        M(Nds(i),Nds(j)) = 1; 
    end
end

% killme = randi(N,1,2);
% M(killme(1),killme(2)) = 0;
% M(killme(2),killme(1)) = 0;
% 
% killme = randi(N,1,2);
% M(killme(1),killme(2)) = 0;
% M(killme(2),killme(1)) = 0;

%diag(M,1) = ones(N-1,1);

M

for itr = 1:nRlz
    X = zeros(1,N); 
    Xclean = zeros(1,N); Noise = zeros(1,N);
    %M = MakeModularNetwork(N,nM,0.2,'Circular');
    %M = M.*abs(rand(N)); %put positive weights 
    
%     Xclean = [];
%     for i = 1:nM
%         RndSign=1;
%         if mod(i,2)
%             RndSign = -1;
%         end
%             Xclean = [Xclean;ones(sM,1).*RndSign];
%     end
    
%%% Add the last block    
    %LastBlock = randi(5,[sM,1]).*((rand(sM,1)>0.5)*2-1); %high frequency
    %LastBlock = ones(sM,1).*(i+1).*RndSign; %low frequency
    
    %Xclean = [Xclean;LastBlock];
    
%     %the last block
     RndSign = ((rand(1,HowMany)>0.5)*2-1);
%     Xclean = [Xclean;3.*RndSign];
    
    
    Xclean(Nds) = 1; 
    %Noise(Nds) = (randn(1,HowMany)./5);
    X = Xclean + Noise;
    Noise(Nds) = ((rand(1,HowMany)>0.5)*2-1);
    X = Xclean .* Noise;
    
    %Noise = ((rand(N,1) > 0.5)*2 - 1); 
    %X = Xclean .* Noise;    
    

    %== Unfiltered
    L = myGSP_LapMat(M);
    Xh(itr) = myGSP_Smoothness(L,X);
    
    %== LP filtered
    lpXf = myGSP_VertexFilter(L,X,lpH);
    lpXf_tmp = myGSP_Smoothness(L,lpXf);
    lpXh(itr) = lpXf_tmp;
    %== HP filtered
    hpXf = myGSP_VertexFilter(L,X,hpH);
    hpXf_tmp = myGSP_Smoothness(L,hpXf);
    hpXh(itr) = hpXf_tmp;

    
     if ~(itr-1)
        %bg = biograph(M);  % make biograph object
        %dolayout(bg);   % automatically calculate positions for nodes
        %view(bg); % what it says on the tin
         
        fh = figure; 
        hs0 = subplot(1,3,1); hold on;
        title('Overal')
        myGSP_plot3D(M,X,'subplot',hs0)
        
        hs1 = subplot(1,3,2); hold on;
        title('Low Pass Filtered')
        myGSP_plot3D(M,lpXf,'subplot',hs1)
        %zlim([0 max(X)])
        
        hs2 = subplot(1,3,3); hold on;
        title('High Pass Filtered')
        myGSP_plot3D(M,hpXf,'subplot',hs2)        
        %zlim([0 max(X)])
        
        set(fh,'color','w')
     end    
    
    
    clear *_tmp
end

disp(['all: ' num2str(mean(Xh)) ', l:' num2str(mean(lpXh)) ', h:' num2str(mean(hpXh))])
[mVG,VG,Grad,TV] = myGSP_VertexGrad(L,X); TV
[mVG,VG,Grad,TV] = myGSP_VertexGrad(L,lpXf); TV
[mVG,VG,Grad,TV] = myGSP_VertexGrad(L,hpXf); TV