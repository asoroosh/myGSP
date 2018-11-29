function M = MakeModularNetwork(N,nM,modens)

if ~exist('modens','var'); modens = 0.9; end; 

%N = 100; 
%nM = 5;
sM = N./nM;
ModulProb = ones(1,nM).*modens;

for i = 1:nM

    Mtmp = binornd(1,ModulProb(i),[sM sM]);
    %density_und(Mtmp)
    M((i-1)*sM+1:i*sM,(i-1)*sM+1:i*sM) = triu(Mtmp,1) + triu(Mtmp,1)';

end
