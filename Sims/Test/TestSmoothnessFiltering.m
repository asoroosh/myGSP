clear

addpath(genpath('/Users/sorooshafyouni/Home/GSP/myGSP'))
addpath(genpath('/Users/sorooshafyouni/Home/GSP/gspbox'))

N  = 100; 
nM = 4;
sM = N./nM;

%A = MakeModularNetwork(N,nM,0.1,'RichClub');

%Remove everything BUT the last CutOff components:
CutOff = 5; 
lpH = @(x) x.*[ones(CutOff,1);zeros(numel(x)-CutOff,1)];
bpH = @(x) x.*[zeros(CutOff,1);ones(numel(x)-2.*CutOff,1);zeros(CutOff,1)];
hpH = @(x) x.*[zeros(numel(x)-CutOff,1);ones(CutOff,1)];

% Noise Comp
X = zeros(N,1);
X = X + 0.3*1/sqrt(N)*randn(N,1);

%X = X./std(X); 


%filter example
%tau = 1;
%h = @(x) 1./(1+tau*x);


% Create a graph
G = gsp_sensor(N);
% Compute the Fourier basis (if the graph is small)
G = gsp_compute_fourier_basis(G);

%%% myGSP

A = full(G.W);
L = myGSP_LapMat(A);

Xhat = myGSP_GFT(L,X);
X2   = myGSP_IGFT(L,Xhat);

%%% GSPBox

Xhat0       = gsp_gft(G,X);
X0          = gsp_igft(G,Xhat0);
lp_X0       = gsp_filter_analysis(G,lpH,X);
bp_X0       = gsp_filter_analysis(G,bpH,X);
hp_X0       = gsp_filter_analysis(G,hpH,X);

%sanity check, assuming that X = X_{L}+X_{B}+X_{H}
figure; hold on; plot(lp_X0+bp_X0+hp_X0); plot(X)

% smoothness from gsp box
fp_smtest  = X'    * G.L *X;
lp_smtest  = lp_X0'* G.L *lp_X0;
bp_smtest  = bp_X0'* G.L *bp_X0;
hp_smtest  = hp_X0'* G.L *hp_X0;

disp(['totalV: ' num2str(fp_smtest) ' LP:' num2str(lp_smtest) ' BP:' num2str(bp_smtest) ' HP:' num2str(hp_smtest)])

% Filter the Data
lp_X   = myGSP_VertexFilter(L,X,lpH);
bp_X   = myGSP_VertexFilter(L,X,bpH);
hp_X   = myGSP_VertexFilter(L,X,hpH);

%sanity check, assuming that X = X_{L}+X_{B}+X_{H}
figure; hold on; plot(lp_X+bp_X+hp_X); plot(X)

% Smoothness from myGSP
TV = myGSP_Smoothness(L,X);
lp_TV = myGSP_Smoothness(L,lp_X);
bp_TV = myGSP_Smoothness(L,bp_X);
hp_TV = myGSP_Smoothness(L,hp_X);

disp(['totalV: ' num2str(TV) ' LP:' num2str(lp_TV) ' BP:' num2str(bp_TV) ' HP:' num2str(hp_TV)])
