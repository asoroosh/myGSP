clear

% Iclean = imread('cameraman.tif');
% Iclean = double(Iclean(93:171,93:171));

% Iclean = imread('ClusterEx/ClusterExample.png');
% Iclean = rgb2gray(Iclean);
% Iclean = double(Iclean);

addpath /Users/sorooshafyouni/Home/GSP/myGSP

Ni = 20;
origin = [0 0 0]; datatype = 64;
WindSize = 3;
Hop = 4;
VoxelSize = [1 1 1];

Iclean = zeros([Ni,Ni,Ni]); %isotropic

% prefix = 'General';
% Iclean(5:15,5:15,5:15) = .8; % THE effect
% Iclean(16:18,16:18,16:18) = .8; 
% Iclean(2:3,2:3,2:3) = 0.8; % tiny effect which is suppose to be extinct
% Iclean(19:20,19:20,19:20) = 0.8; % a cub on the edge

prefix = 'PeakRplc';
Iclean(5:15,5:15,5:15) = .4; % THE effect
Iclean(8:10,8:10,8:10) = .6; % THE effect
Iclean(13:15,13:15,13:15) = .6; % THE effect

%%%%=======================================================================
%%%%============================= Remaining ===============================
%%%%=======================================================================

[Ni,Nj,Nz] = size(Iclean);
P = Ni.*Nj*Nz;

Iclean = Iclean./max(Iclean(:));
I = Iclean + (randn(Ni,Nj,Nz)/10);

Inii_tmp = make_nii(Iclean, VoxelSize, origin, datatype);    % default voxel_size
save_nii(Inii_tmp,['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_IClean.nii'])

Inii_tmp = make_nii(I, VoxelSize, origin, datatype);    % default voxel_size
save_nii(Inii_tmp,['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_I.nii'])

B10 = imgaussfilt3(I,1,'FilterSize',[WindSize WindSize WindSize]);
B15 = imgaussfilt3(I,1.5,'FilterSize',[WindSize WindSize WindSize]);
B35 = imgaussfilt3(I,3.5,'FilterSize',[WindSize WindSize WindSize]);

Inii_tmp = make_nii(B10, VoxelSize, origin, datatype);    % default voxel_size
save_nii(Inii_tmp,['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_B10.nii'])
Inii_tmp = make_nii(B15, VoxelSize, origin, datatype);    % default voxel_size
save_nii(Inii_tmp,['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_B15.nii'])
Inii_tmp = make_nii(B35, VoxelSize, origin, datatype);    % default voxel_size
save_nii(Inii_tmp,['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_B35.nii'])

spm_smooth(['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_I.nii'],['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_FWHM2mm.nii'],2)
spm_smooth(['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_I.nii'],['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_FWHM3mm.nii'],3)
spm_smooth(['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_I.nii'],['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/' prefix '_FWHM5mm.nii'],5)

for pi = 1:numel(I)
    if ~mod(pi,1000); disp(pi); end
    [i,j,z] = ind2sub(size(I),pi);        
    for n = -Hop:Hop
        for m = -Hop:Hop
            for l = -Hop:Hop
                jj = j+m; ii = i+n; zz = z+l;
            
                if ii<=0 || jj<=0 || zz<=0 || jj>Nj || ii>Ni || zz>Nz; continue; end;                
                pj = sub2ind(size(I),ii,jj,zz);
            
                Dist_tmp = double(abs(I(pi)-I(pj)));
                Dist(pi,pj) = Dist_tmp;
                %W(pi,pj) = GuassKernel(Dist_tmp); 
            end
        end
    end
end

%Dist = Dist./max(Dist(:));
theta =0.1; 
k = 0.1;
W = GuassKernel(Dist,theta,k); 
 
[~,U0,V0] = myGSP_GFT(W);
% 
tau = 8;
H_LP = @(x) 1./(1+tau*x);
 
Iv = double(reshape(I,P,1));
Ht = double(diag(H_LP(V0)));

Ht_hat = U0*Ht*U0';

Wf = Ht_hat*Iv;
Wf = Wf./max(Wf);
Wf = reshape(Wf,[Ni,Nj,Nz]);
%Wf = myGSP_FreqFilter(W,[],H_LP);


Inii_tmp = make_nii(Wf, [2 2 2], origin, datatype);    % default voxel_size
save_nii(Inii_tmp,['/Users/sorooshafyouni/Home/GSP/ClusterEx/3D/If_' prefix '_' num2str(Hop) '_tau' num2str(tau) '_theta' num2str(theta) '_k' num2str(k) '.nii'])
clear *_tmp
