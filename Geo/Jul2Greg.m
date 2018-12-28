function [Date,sDate] = Jul2Greg(jDate)
% spits out 3 element array and a string of Greg dates
% SA, Ox, 2018
%
[year,month,day] = julian2greg(jDate);
Date = [day,month,year];
sDate = [num2str(day) '/' num2str(month) '/' num2str(year)];
end


function [year,month,day,hour,minu,sec,dayweek,dategreg] = julian2greg(JD)
% ______________________________________________________________________________________________
% This function converts the Julian dates to Gregorian dates.
%
% 4. Notes:
%     - For all common era (CE) dates in the Gregorian calendar.
%     - The function was tested, using  the julian date converter of U.S. Naval Observatory and
%     the results were similar. You can check it.
%     - Trying to do the life... more easy with the conversions.
%
% 5. Referents:
%     Astronomical Applications Department. "Julian Date Converter". From U.S. Naval Observatory.
%               http://aa.usno.navy.mil/data/docs/JulianDate.html
%     Duffett-Smith, P. (1992).  Practical Astronomy with Your Calculator.
%               Cambridge University Press, England:  pp. 8,9.
%
%Copyright (c) 2006, Gabriel Ruiz
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are
%met:
%
%    * Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in
%      the documentation and/or other materials provided with the distribution
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%POSSIBILITY OF SUCH DAMAGE.

% Gabriel Ruiz Mtz.
% Jun-2006
% ____________________________________________________________________________________________

%error(nargchk(1,1,nargin))

I = floor( JD + 0.5);
Fr = abs( I - ( JD + 0.5) );	 

if I >= 2299160 
     A = floor( ( I- 1867216.25 ) / 36524.25 );
     a4 = floor( A / 4 );
     B = I + 1 + A - a4;
else
     B = I;
end 

C = B + 1524;
D = floor( ( C - 122.1 ) / 365.25 );
E = floor( 365.25 * D );
G = floor( ( C - E ) / 30.6001 );
day = floor( C - E + Fr - floor( 30.6001 * G ) );

if G <= 13.5 
    month = G - 1;
else
    month = G - 13;
end

if month > 2.5
    year = D - 4716;
else
    year = D - 4715;
end

hour = floor( Fr * 24 );
minu = floor( abs( hour -( Fr * 24 ) ) * 60 );
minufrac = ( abs( hour - ( Fr * 24 ) ) * 60 ); 
sec = ceil( abs( minu - minufrac ) * 60);
AA = ( JD + 1.5 ) / 7;
nd = floor( (abs( floor(AA) - AA ) ) * 7 );
dayweek ={ 'Sunday' 'Monday' 'Tuesday' 'Wednesday' 'Thursday' 'Friday' 'Saturday'};
dayweek = dayweek{ nd+1};
format('long', 'g');
dategreg = [ day month year hour minu sec ];
	   
end