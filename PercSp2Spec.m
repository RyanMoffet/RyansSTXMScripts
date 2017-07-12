function [sp2out,dsp2]=PercSp2Spec(Specin)
%% Calculates the % sp2 of a stack (S.spectr) region specified by linidxin
%% S.spectr is the stack data aligned and converted to OD
%% linidxin is the linear index defining the region over which to determine
%% the % sp2
%% 081201 Ryan C. Moffet 
energy=Specin(:,1);
Partspec=Specin(:,2);
Partspec=Partspec-mean(Partspec(1:3));  %% baseline subtract
%% calculate % sp2 based on Hopkins et al.
pre = [280,283];
Tot = [280,310];
CCPeak = [284,287];
nidx=find(energy >= pre(1) & energy <= pre(2));
totidx=find(energy > Tot(1) & energy < Tot(2));
CCidx=find(energy > CCPeak(1) & energy < CCPeak(2));
Atot=trapz(energy(totidx),Partspec(totidx));
ACC=trapz(energy(CCidx),Partspec(CCidx));

uptot=trapz(energy(totidx),Partspec(totidx)+std(Partspec(nidx)));
ultot=trapz(energy(totidx),Partspec(totidx)-std(Partspec(nidx)));
dtot=uptot-ultot;
upCC=trapz(energy(CCidx),Partspec(CCidx)+std(Partspec(nidx)));
ulCC=trapz(energy(CCidx),Partspec(CCidx)-std(Partspec(nidx)));
dcc=upCC-ulCC;
sp2out=ACC./Atot.*8.6%%8.8183; for 284.5,287
dsp2=(sqrt((dtot./Atot).^2+(dcc./ACC).^2)).*sp2out;
