function myGSP_plot3D(A,X,varargin)

assert(size(A,1)==size(A,2))
assert(size(A,1)==numel(X))

N = numel(X);


if sum(strcmpi(varargin,'subplot'))
   h  = varargin{find(strcmpi(varargin,'subplot'))+1};
   subplot(h)
elseif sum(strcmpi(varargin,'figure'))
   h  = varargin{find(strcmpi(varargin,'figure'))+1};
   figure(hndl)
else
   h = figure; hold on; box on;
end

labelflag = 0;
if sum(strcmpi(varargin,'label'))
    labelflag = 1;
end

%normalise and then inflate the weights
W = abs(A);
W = W./max(W(:));

if numel(unique(W(:)))==2
    %disp('myGSP_plot3D: There are only one element in the whole thing.')
    W = W.*1;
else
    W = W.*3;
end

A = triu(A,1);
% binarise the matrix
A(A>0 | A<0) = 1; 

theta = linspace(0,2*pi,N+1); theta(end) = [];
%theta = theta(1:end-1);
[x,y] = pol2cart(theta,1);
[ind1,ind2]=ind2sub(size(A),find(A(:)));

%clf(h);
plot(x,y,'.k','markersize',20,'linestyle','none');
hold on
arrayfun(@(p,q)line([x(p),x(q)],[y(p),y(q)],'color','k','linewidth',W(p,q)),ind1,ind2)
for n = 1:N
    if X(n)<0
        line([x(n) x(n)],[y(n) y(n)],[0 X(n)],'color','b')
    elseif X(n)>0
        line([x(n) x(n)],[y(n) y(n)],[0 X(n)],'color','r')
    elseif ~X(n)
        continue;
    else
        error('huh?!')
    end
end

if labelflag 
    txt = cellstr(num2str((1:N)','%02d'));
    htext = text(x.*1.05,y.*1.05, txt, 'FontSize',8);
    set(htext,{'Rotation'},num2cell(theta*180/pi)')
end

axis square off
view(20,60)
set(h,'color','w')

