clear

N = 100;
T = 200;

X = randn(N,T);

M = MakeModularNetwork(N,5,0.99,'Circular');

L = myGSP_LapMat(M);

[mVG0,VG0,Grad0,TV0] = myGSP_VertexGrad(L,X,'correlation');

[mVG1,VG1,Grad1,TV1] = myGSP_VertexGrad(L,X);