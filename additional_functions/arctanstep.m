function a = arctanstep(x,pos,wid)
% 
%x = linspace(280,305,1000);
%pos = 290;
%wid = 1;
xp = (x-pos)*0.991/(wid/2);
a = atan(xp);
