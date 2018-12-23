function DD = myGSP_DgrMinSec2DecDgr(DgrMinSec)
%
% DecDgr = myGSP_DgrMinSec2DecDgr(DgrMinSec)
% Convets Degree Minutes Seconds to Decimal Degrees
%
% DgrMinSec : should be a three element vector/matrix of [dgr, min, sec]
% DD: decimal degree
%
%%%Example:
% DD coordinates  = 51.752728, -1.214899;
% DMS coordinates = 51°45'09.8"N 1°12'53.6"W
%
% [51 45 09.8]
% DD = myGSP_DgrMinSec2DecDgr([51 45 09.8])
%
% [1 12  53.6]
% DD = myGSP_DgrMinSec2DecDgr([1 12  53.6])
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com 

DD = DgrMinSec(:,1) + DgrMinSec(:,2)/60 + DgrMinSec(:,3)./3600;