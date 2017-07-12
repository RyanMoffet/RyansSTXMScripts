function [Ain,Acarb]=AInACarb(S,linidxin)
%% the inorgaic and total carbon contributions of a stack (S.spectr) region 
%% specified by linidxin
%% S.spectr is the stack data aligned and converted to OD
%% linidxin is the linear index defining the region over which to determine
%% the % sp2
%% 081208 Ryan C. Moffet 

Spectr=S.spectr;
energy=S.eVenergy;

%% Average spectrum over region specified by linear index "linidxin"
Partspec=zeros(1,length(energy));
for j=1:length(energy)
    junkmat=Spectr(:,:,j);
    Partspec(j)=mean(mean(junkmat(linidxin)));
end

%% Approximate Inorganic by linear extrapolation of pre-edge
x1temp=[energy(1),282];
x2temp=[282,283];

x1idx=find(energy<x1temp(2));
x2idx=find(energy>x2temp(1) & energy<x2temp(2));
x1=mean(energy(x1idx));
x2=mean(energy(x2idx));
y1=mean(Partspec(x1idx));
y2=mean(Partspec(x2idx));
m=(y2-y1)/(x2-x1);
y=m.*energy-m*x1+y1;  

%% Calculate Areas
Ain=trapz(energy,y);
Atot=trapz(energy,Partspec);
Acarb=Atot-Ain;

