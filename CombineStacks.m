%% CombineStacks
%S1: lower energy stack....

function Scomplete=CombineStacks(S1,S2)

Scomplete=S1;
spectr1=S1.spectr;
spectr2=S2.spectr;

[s1y,s1x,s1eV]=size(S1.spectr);
[s2y,s2x,s2eV]=size(S2.spectr);

xresolution=S1.Xvalue/s1x;      % Will be used to calculate new Scomplete.Xvalue etc...
yresolution=S1.Yvalue/s1y;

comby=min(s1y,s2y);
combx=min(s1x,s2x);

floatshifts=dftregistration(fft2(S1.spectr(1:comby,1:combx,ceil(s1eV*1/10))),fft2(S2.spectr(1:comby,1:combx,ceil(s2eV*1/10))),100);        %Calculate Stack shift

intshifts=fix(floatshifts);
fracshifts=floatshifts-intshifts;

for k=1:s2eV            %Shift 2nd Stack images
    
    spectr2(:,:,k)=FTMatrixShift(spectr2(:,:,k),-fracshifts(3),-fracshifts(4));
    
end

%Remove circulated pixel lines
if floatshifts(3) > 0           
    
    spectr2(1,:,:)=[];
    
elseif floatshifts(3) < 0
    
    spectr2(s2y,:,:)=[];
    
end

if floatshifts(4) > 0 
    
    spectr2(:,1,:)=[];
    
elseif floatshifts(4) < 0
    
    spectr2(:,s2x,:)=[];
    
end;

[s2y,s2x,s2eV]=size(spectr2);

%Shift Matrix Construction
if s1y+abs(intshifts(3)) > s2y
    
    ysm=s1y+abs(intshifts(3));
    
elseif s1y+abs(intshifts(3)) <= s2y
    
    ysm = s2y;
    
end

if s1x+abs(intshifts(4)) > s2x
    
    xsm=s1x+abs(intshifts(4));
    
elseif s1x+abs(intshifts(4)) <= s2x
    
    xsm = s2x;
    
end

ShiftMatrix=zeros(ysm,xsm,s1eV+s2eV);

% Calculation of shift borders for transfer of S1 and S2 into Shift Matrix

if intshifts(3) < 0
    
    S1ystart=abs(intshifts(3))+1;
    S2ystart=1;
    S1ystop=S1ystart+s1y-1;
    S2ystop=S2ystart+s2y-1;
    
elseif intshifts(3) == 0
    
    S1ystart=1;
    S2ystart=1;    
    S1ystop=S1ystart+s1y-1;
    S2ystop=S2ystart+s2y-1;
    
elseif intshifts(3) > 0
    
    S1ystart=1;
    S2ystart=abs(intshifts(3))+1;
    S1ystop=S1ystart+s1y-1;    
    S2ystop=S2ystart+s2y-1;
    
end

if intshifts(4) < 0
    
    S1xstart=abs(intshifts(4))+1;
    S2xstart=1;
    S1xstop=S1xstart+s1x-1;
    S2xstop=S2xstart+s2x-1;
    
elseif intshifts(4) == 0
    
    S1xstart=1;
    S2xstart=1;    
    S1xstop=S1xstart+s1x-1;
    S2xstop=S2xstart+s2x-1;
    
elseif intshifts(4) > 0
    
    S1xstart=1;
    S2xstart=abs(intshifts(4))+1;
    S1xstop=S1xstart+s1x-1;    
    S2xstop=S2xstart+s2x-1;
    
end

% Transfer of S1 and S2 into Shift Matrix

ShiftMatrix(S1ystart:S1ystop,S1xstart:S1xstop,1:s1eV)=spectr1(:,:,:);
ShiftMatrix(S2ystart:S2ystop,S2xstart:S2xstop,(s1eV+1):(s1eV+s2eV))=spectr2(:,:,:);

% Energy data reconstruction for combined Stack
eVenergy=zeros((s1eV+s2eV),1);                        
eVenergy(1:s1eV)=S1.eVenergy;
eVenergy((s1eV+1):(s1eV+s2eV))=S2.eVenergy;
Scomplete.eVenergy=eVenergy;

% Izero data reconstruction for combined Stack
% izero=zeros((s1eV+s2eV),2);                        
% izero(1:s1eV,:)=S1.Izero;
% izero((s1eV+1):(s1eV+s2eV),:)=S2.Izero;
% Scomplete.Izero=izero;

%Calculate overlapping pixel region
cutymin=max(S1ystart,S2ystart);
cutymax=min(S1ystop,S2ystop);
cutxmin=max(S1xstart,S2xstart);
cutxmax=min(S1xstop,S2xstop);


Scomplete.spectr=ShiftMatrix(cutymin:cutymax,cutxmin:cutxmax,:);

S.Xvalue=size(Scomplete.spectr,2)*xresolution;
S.Yvalue=size(Scomplete.spectr,1)*yresolution;

return