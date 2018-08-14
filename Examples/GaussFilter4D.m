clear

addpath /Users/sorooshafyouni/Home/GSP/myGSP

% Iclean = imread('cameraman.tif');
% Iclean = double(Iclean(93:171,93:171));

% Iclean = imread('ClusterEx/2D/ClusterExample.png');
% Iclean = rgb2gray(Iclean);
% Iclean = double(Iclean);

%Is = 50;

Is = 14;

I_idx = zeros(Is,Is,Is);
I_idx(5:10,5:10,5:10)= 1;
I_idx(2:3,2:3,2:3)= 1;
I_idx(11:14,11:14,11:14)= 1;

origin = [0 0 0]; datatype = 64;
VoxelSize = [1 1 1];
prefix = 'BlockDesign_VertexFiltering';
LowPassCutOff = 100; %meaning after from 500 to end is set to zero on the transfer function 

% Signal:
load('SimfMRIts/BlockDesign_400_20stim_TR2.mat','ts')
%ts = ts+10;
%ts = ts./max(ts);

SNR = 2; 

%plot(t,y);
T = size(ts,1);
for i = 1:Is
    for j = 1:Is
        for z = 1:Is
            if I_idx(i,j,z) 
                I(i,j,z,:) = (randn(T,1)./SNR)+ts;
                Iclean(i,j,z,:) = ts;
            else
                I(i,j,z,:) = (randn(T,1)./SNR)';
                Iclean(i,j,z,:) = ones(T,1);
            end
        end
    end
end

%I = I./max(I(:));

[Ni,Nj,Nz,T] = size(I);
P = Ni.*Nj*Nz;

save_nii(make_nii(Iclean, VoxelSize, origin, datatype),['/Users/sorooshafyouni/Home/GSP/SimfMRIts/' prefix '_IClean_VS' num2str(VoxelSize(1)) 'mm_SNR' num2str(SNR) '.nii'])
save_nii(make_nii(I, VoxelSize, origin, datatype),['/Users/sorooshafyouni/Home/GSP/SimfMRIts/' prefix '_I_VS' num2str(VoxelSize(1)) 'mm_SNR' num2str(SNR) '.nii'])

for sl = [2 3 5]
    spm_smooth(['/Users/sorooshafyouni/Home/GSP/SimfMRIts/' prefix '_I_VS' num2str(VoxelSize(1)) 'mm_SNR' num2str(SNR) '.nii'],['/Users/sorooshafyouni/Home/GSP/SimfMRIts/' prefix '_FWHM' num2str(sl) '_VS' num2str(VoxelSize(1)) '_mm_SNR' num2str(SNR) '.nii'],sl)
end

WindSize = 3;
Hop = 8;

% B10 = imgaussfilt3(I,1,'FilterSize',[WindSize WindSize]);
% B15 = imgaussfilt3(I,1.5,'FilterSize',[WindSize WindSize]);
% B35 = imgaussfilt3(I,3.5,'FilterSize',[WindSize WindSize]);

Iv = double(reshape(I,P,T));
Icleanv = double(reshape(Iclean,P,T));

for pi = 1:P
    if ~mod(pi,1000); disp(pi); end
    [i,j,z] = ind2sub([Ni Nj Nz],pi);        
    for n = -Hop:Hop
        for m = -Hop:Hop
            for l = -Hop:Hop            
                jj = j+m; ii = i+n; zz = z+l;

                if ii<=0 || jj<=0 || zz<=0 || jj>Nj || ii>Ni || zz>Nz; continue; end;                
                pj = sub2ind([Ni Nj Nz],ii,jj,zz);

                %Difference
                %Dist_tmp = double(abs(I(pi)-I(pj)));

                %Inverse correlation 
                %Dist_tmp = 1./double(abs( corr(Iv(pj,:)',Iv(pi,:)') ));

                %Eculdian distance
                %Dist_tmp = sqrt(sum((Iv(pj,:)-Iv(pi,:)).^2));

                %FrechetDist
                Dist_tmp = DiscreteFrechetDist(Iv(pj,:),Iv(pi,:));

                Dist(pi,pj) = Dist_tmp;
                %W(pi,pj) = GuassKernel(Dist_tmp); 
            end
        end
    end
end

Dist = Dist./max(Dist(:)); 
figure; imagesc(Dist)
theta =0.1; 
k = 0.1;
W = GuassKernel(Dist,theta,k); 
 
[~,U0,V0] = myGSP_GFT(W);

% Frequency filtering
% tau = 10;
% H_LP = @(x,tau) 1./(1+tau*x);
% Ht = double(diag(H_LP(V0)));

% Vertex Filtering
% tau = ['LPCO' num2str(LowPassCutOff) ];
% Ht = eye(size(U0));
% Ht(LowPassCutOff:end,LowPassCutOff:end) = 0;

%Tukey tapering 
tau = ['LPCO_TukeyCosine' num2str(LowPassCutOff) ];
wtt = tukeywin(2*LowPassCutOff,0.5);
wtt = wtt(round(numel(wtt)/2):end);
Ht = diag([wtt;zeros(P-numel(wtt),1)]);


Ht_hat = U0*Ht*U0';
Wfv    = Ht_hat*Iv;
%Wfv = Wfv./max(Wfv); %this is not necessary -- just fucks up the results!
Wf     = reshape(Wfv,Ni,Nj,Nz,T);

save_nii(make_nii(Wf, VoxelSize, origin, datatype),['/Users/sorooshafyouni/Home/GSP/SimfMRIts/' prefix '_hop' num2str(Hop) '_tau' num2str(tau) '_theta' num2str(theta) '_k' num2str(k) '_SNR' num2str(SNR) '_Wf.nii'])

figure; 
hold on; box on; 
plot(squeeze(Iclean(7,7,7,:)),'color',[0 0 0],'linewidth',1.5)
plot(squeeze(I(7,7,7,:)),'color',[1 0 0],'linewidth',1.5)
plot(squeeze(Wf(7,7,7,:)),'color',[0 0 1],'linewidth',1.5)
legend('Synthetic BOLD','Synthetic BOLD + Noise','Graph-Based Filtered BOLD')

