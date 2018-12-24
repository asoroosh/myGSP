function [WGSLat, WGSLon] = OSGB36toWGS84(easting,northing)
% [WGSLat, WGSLon] = OSGB36toWGS84(easting,northing)
% converts OSGB36 coordinates to WGS84 Lat Long
% 
% inspired by: https://github.com/LambethCouncil/OSGB36_Converter
% tested by: http://www.bgs.ac.uk/data/webservices/convertForm.cfm#bngToLatLng
%
%%%REFERENCE:
% Ordnance Survey Great Britain 
% GEODESY & POSITIONING
% A Guide to Coordinate Systems in Great Britain
% An introduction to mapping coordinate systems 
% and the use of GNSS datasets with Ordnance 
% Survey mapping (Annex C)
%
%
% Soroosh Afyouni, University of Oxford, 2018
% srafyouni@gmail.com 
%

[OSGBLat,OSGBLon] = to_OSGB36(easting, northing);
[WGSLat, WGSLon]  = to_WGS84(OSGBLat,OSGBLon);

end

% hmmm, Matlab has all of these, but just in case...
function RAD = deg_to_rad(degrees); RAD = degrees / 180.0 * pi; end
function DGR = rad_to_deg(r); DGR = (r/pi)*180; end
function S = sin_pow_2(x); S = sin(x) * sin(x); end
function C = cos_pow_2(x); C = cos(x) * cos(x); end
function T = tan_pow_2(x); T = tan(x) * tan(x); end
% Matlab has a Secant function!
%function SC = sec(x); SC = 1.0 / cos(x); end

function [OSGBlat,OSGBlon] = to_OSGB36(easting, northing)
  % [OSGBlat,OSGBlon] = to_OSGB36(easting, northing)
  % OSGB36 Easting/Northing >> OSGB36 Latitude and Longitude
  % SA, Ox, 2018
  %
    OSGB_F0  = 0.9996012717;
    N0       = -100000.0;
    E0       = 400000.0;
    phi0     = deg_to_rad(49.0);
    lambda0  = deg_to_rad(-2.0);
    a        = 6377563.396;
    b        = 6356256.909;
    eSquared = (( a^2) - ( b^2)) / ( a^2);
    
    %phi      = 0; godbless Matlab!
    %lambda   = 0; godbless Matlab!
    
    E        = easting;
    N        = northing;
    n        = ( a -  b) / ( a +  b);
    M        = 0.0;
    phiPrime = (( N -  N0) / ( a *  OSGB_F0)) +  phi0;
	     
    while (( N -  N0 -  M) >= 0.001)

        M   = ( b *  OSGB_F0)...
            * (((1 +  n + ((5.0 / 4.0) *  n *  n) + ((5.0 / 4.0) *  n *  n *  n))...
            * ( phiPrime -  phi0))...
            - (((3 *  n) + (3 *  n^2) + ((21.0 / 8.0) *  n^3))...
            * sin( phiPrime -  phi0) * cos( phiPrime +  phi0))...
            + ((((15.0 / 8.0) *  n^2) + ((15.0 / 8.0) *  n^3))...
            *  sin(2.0 * ( phiPrime -  phi0))...
            *  cos(2.0 * ( phiPrime +  phi0)))...
            - (((35.0 / 24.0) *  n^3)...
            *  sin(3.0 * ( phiPrime -  phi0))...
            *  cos(3.0 * ( phiPrime +  phi0))));

        phiPrime = phiPrime + ( N -  N0 -  M) / ( a *  OSGB_F0);

    end 
	     
    v   =  a *  OSGB_F0 * ((1 -  eSquared * sin_pow_2( phiPrime)) ^ -0.5);
    rho = a *  OSGB_F0 * (1 -  eSquared)...
     * ((1.0 -  eSquared * sin_pow_2( phiPrime)) ^ -1.5);

    etaSquared = (v/rho)-1;

    VII =  tan( phiPrime)/(2*rho*v);

    %should be checked for paranthesis
    VIII = tan(phiPrime) / (24.0 * rho * (v ^ 3.0))...
       * (5.0 + (3.0 * tan_pow_2( phiPrime))...
       +  etaSquared...
       - (9.0 * tan_pow_2( phiPrime) *  etaSquared));

    IX = (tan(phiPrime) / (720.0 *  rho * (v ^ 5.0)))...
     * (61.0 + (90.0 * tan_pow_2(phiPrime))...
     + (45.0 * tan_pow_2( phiPrime) * tan_pow_2(phiPrime)));

    X = sec(phiPrime) / v;

    XI = (sec(phiPrime) / (6.0 *  v *  v *  v))...
     * (( v /  rho) + (2 * tan_pow_2( phiPrime)));

    XII = (sec(phiPrime) / (120.0 * ( v ^ 5.0)))...
       * (5.0 + (28.0 * tan_pow_2(phiPrime))...
       + (24.0 * tan_pow_2(phiPrime) * tan_pow_2(phiPrime)));

    XIIA = (sec(phiPrime) / (5040.0 * ( v ^ 7.0)))...
     * (61.0...
       + (662.0 * tan_pow_2(phiPrime))...
       + (1320.0 * tan_pow_2(phiPrime) * tan_pow_2(phiPrime))...
       + (720.0...
         * tan_pow_2(phiPrime)...
         * tan_pow_2(phiPrime)...
         * tan_pow_2(phiPrime)));

    phi = phiPrime...
     - ( VII * (( E -  E0) ^ 2.0))...
     + ( VIII * (( E -  E0) ^ 4.0))...
     - ( IX * (( E -  E0) ^ 6.0));

    lambda = lambda0...
     + ( X * ( E -  E0))...
     - ( XI * (( E -  E0) ^ 3.0))...
     + ( XII * (( E -  E0) ^ 5.0))...
     - ( XIIA * (( E -  E0) ^ 7.0));

    OSGBlat = rad_to_deg(phi);
    OSGBlon = rad_to_deg(lambda);
	     
	  end
	  

function [WGSLat, WGSLon] = to_WGS84(latitude,longitude)
% [WGSLat, WGSLon] = to_WGS84(latitude,longitude)
% OSGB36 Latitude and Longitude >> WGS84 Latitude and Longitude
% SA, Ox, 2018
%
  a         = 6377563.396;
  b         = 6356256.909;
  eSquared  = ((a^2) - (b^2)) / (a^2);

  phi       = deg_to_rad(latitude);
  lambda    = deg_to_rad(longitude);
  v         = a / (sqrt(1 - eSquared * sin_pow_2(phi)));
  H         = 0;
  x         = (v + H) * cos(phi) *  cos(lambda);
  y         = (v + H) * cos(phi) *  sin(lambda);
  z         = ((1 - eSquared) * v + H) *  sin(phi);

  tx =        446.448;
  ty =       -124.157;
  tz =        542.060;

  s  =         -0.0000204894;
  rx = deg_to_rad( 0.00004172222);
  ry = deg_to_rad( 0.00006861111);
  rz = deg_to_rad( 0.00023391666);

  xB = tx + (x * (1 + s)) + (-rx * y)     + (ry * z);
  yB = ty + (rz * x)      + (y * (1 + s)) + (-rx * z);
  zB = tz + (-ry * x)     + (rx * y)      + (z * (1 + s));

  a        = 6378137.000;
  b        = 6356752.3141;
  eSquared = ((a^2) - (b^2)) / (a^2);

  lambdaB = rad_to_deg( atan(yB / xB));
  p       = sqrt((xB^2)+(yB^2));
  phiN    = atan(zB/(p*(1-eSquared)));

  for i = 1:10
    v = a / (sqrt(1 - eSquared * sin_pow_2(phiN)));
    phiN1 = atan((zB + (eSquared * v *  sin(phiN))) / p);
    phiN = phiN1;
  end

  phiB   = rad_to_deg(phiN);
  WGSLat = phiB; 
  WGSLon = lambdaB; 
         
end

      