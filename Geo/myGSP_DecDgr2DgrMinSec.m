function DgrMinSec = myGSP_DecDgr2DgrMinSec(DD)
%
% DecDgr = myGSP_DecDgr2DgrMinSec(DgrMinSec)
% Convets Decimal Degrees to Degree Minutes Seconds 
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com 

sDD = sign(DD);
DD  = abs(DD); 
D   = floor(DD);
M   = floor((DD-D)*60); 
S   = (DD-D-(M/60))*3600;

DgrMinSec = [sDD*D M S]; 