function jDate = Greg2Jul(Date)
% for slash seperated dates, used in UKB
% SA, Ox, 2018
%
DateNum = str2double(split(Date,'/'));
t = datetime(DateNum(3),DateNum(2),DateNum(1));
jDate = juliandate(t);
