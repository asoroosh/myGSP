function D = myGSP_HaversineDist(dlon1,dlon2,dlat1,dlat2)
% D = myGSP_HaversineDistance(dlon1,dlon2,dlat1,dlat2)
%
% Calculates the Haversine Distance between two geo point. 
% Long and Lat should all be decimal degree
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com 

rlon1 = deg2rad(dlon1); rlon2 = deg2rad(dlon2);
rlat1 = deg2rad(dlat1); rlat2 = deg2rad(dlat2);
 
% Haversine formula 
dlon = rlon2 - rlon1; 
dlat = rlat2 - rlat1; 
a = sin(dlat./2).^2 + cos(rlat1) .* cos(rlat2) .* sin(dlon./2).^2;
c = 2 .* asin(sqrt(a)); 
r = 6371; % Radius of earth in kilometers.

%Tadaaa
D = c.*r; 
end