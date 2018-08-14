clear

% Iclean = imread('cameraman.tif');
% Iclean = double(Iclean(93:171,93:171));

addpath /Users/sorooshafyouni/Home/GSP/myGSP

Iclean = imread('ClusterEx/2D/ClusterExample.png');
Iclean = rgb2gray(Iclean);
Iclean = double(Iclean);

[Ni,Nj] = size(Iclean);
P = Ni.*Nj;

Iclean = Iclean./max(Iclean(:));
I = Iclean + (randn(Ni,Nj)/10);

WindSize = 3;
Hop = 4;

B10 = imgaussfilt(I,1,'FilterSize',[WindSize WindSize]);
B15 = imgaussfilt(I,1.5,'FilterSize',[WindSize WindSize]);
B35 = imgaussfilt(I,3.5,'FilterSize',[WindSize WindSize]);

for pi = 1:numel(I)
    if ~mod(pi,1000); disp(pi); end
    [i,j] = ind2sub(size(I),pi);        
    for n = -Hop:Hop
        for m = -Hop:Hop
            jj = j+m; ii = i+n;
            
            if ii<=0 || jj<=0 || jj>Nj || ii>Ni; continue; end;                
            pj = sub2ind(size(I),ii,jj);
            
            Dist_tmp = double(abs(I(pi)-I(pj)));
            Dist(pi,pj) = Dist_tmp;
            %W(pi,pj) = GuassKernel(Dist_tmp); 
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
Wf = reshape(Wf,Ni,Nj);
%Wf = myGSP_FreqFilter(W,[],H_LP);


figure; 
subplot(1,6,1)
box on; axis tight; axis square; 
title(['Original Image'])
imagesc(Iclean); colormap gray

subplot(1,6,2)
box on; axis tight; axis square; 
title(['Noise (sigma = 1/10) Image'])
imagesc(I); colormap gray

subplot(1,6,3)
box on; axis tight; axis square; 
title(['Guassian of filter of sigma = 1.0'])
imagesc(B10); colormap gray

subplot(1,6,4)
box on; axis tight; axis square; 
title(['Guassian of filter of sigma = 1.5'])
imagesc(B15); colormap gray

subplot(1,6,5)
box on; axis tight; axis square; 
title(['Guassian of filter of sigma = 3.5'])
imagesc(B35); colormap gray

subplot(1,6,6)
box on; axis tight; axis square; 
title(['Graph-based anistropic diffiusion smoothing'])
imagesc(Wf); colormap gray