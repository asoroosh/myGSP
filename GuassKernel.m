function [W] = GuassKernel(Dist,theta,k)

if nargin==1; theta = 0.1; k = 0.1; end

Dist = double(Dist);
W = zeros(size(Dist));
W = exp( -( (Dist.^2) ./ (2.*theta.^2) ) );
W(find(Dist<=k)) = 0;

% 
% if Dist<=k
%     W = exp( -( (Dist.^2) ./ (2.*theta.^2) ) );
% else
%     W = 0;
% end

end