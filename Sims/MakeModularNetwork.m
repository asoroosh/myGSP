function M = MakeModularNetwork(N,nM,modens,NetMode)
% simulate modular networks
% SA, Ox, 2018
%
if ~exist('modens','var');  modens = 0.9; end; 
if ~exist('NetMode','var'); NetMode = 'Circular'; end; 

sM = N./nM;
ModulProb = ones(1,nM).*modens;

for i = 1:nM
    Mtmp = binornd(1,ModulProb(i),[sM sM]);
    %density_und(Mtmp)
    M((i-1)*sM+1:i*sM,(i-1)*sM+1:i*sM) = triu(Mtmp,1) + triu(Mtmp,1)';
    
    connectornode(i) = randi([(i-1)*sM+1 i*sM]);
end


%If you want to have the connectors be fully connected to each other

switch NetMode
    case 'RichClub'
        for i = connectornode'
            for j = connectornode'
               M(i,j) = 1;
               M(j,i) = 1;
            end
        end
    case 'Circular'
        %If you wanna have them form a circle
        for i = 1:numel(connectornode)-1
            ii = connectornode(i); 
            jj = connectornode(i+1);
            M(ii,jj) = 1;
            M(jj,ii) = 1;
        end
    case 'Isolated'
        return;
    otherwise
            error('choose either Circular, RichClub or Isolated')
end
