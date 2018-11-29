function myGSP_plot3D(A,X)

assert(size(A,1)==size(A,2))
assert(size(A,1)==numel(X))

A(A>0 | A<0) = 1;

N = numel(X);

%figure; hold on; grid on;

theta = linspace(0,2*pi,N); 
%theta = theta(1:end-1);
[x,y] = pol2cart(theta,1);
[ind1,ind2]=ind2sub(size(A),find(A(:)));

h = figure(1);
clf(h);
plot(x,y,'.k','markersize',20);
hold on
arrayfun(@(p,q)line([x(p),x(q)],[y(p),y(q)],'color','k'),ind1,ind2)

for n = 1:N
    if X(n)<0
        line([x(n) x(n)],[y(n) y(n)],[0 X(n)],'color','b')
    elseif X(n)>0
        line([x(n) x(n)],[y(n) y(n)],[0 X(n)],'color','r')
    else
        error('huh?!')
    end
end

axis square off
view(20,60)

