function [sp2out]=PercSp2Region(S,linidxin)
%% Calculates the % sp2 of a stack (S.spectr) region specified by linidxin
%% S.spectr is the stack data aligned and converted to OD
%% linidxin is the linear index defining the region over which to determine
%% the % sp2
%% 081201 Ryan C. Moffet 

Spectr=S.spectr;
energy=S.eVenergy;
beidx=find(energy<283.5);
% % Spectr=Spectr-min(Spectr(1:3,2));  %% baseline subtract
%% Average spectrum over region specified by linear index "linidxin"
Partspec=zeros(1,length(energy));
for j=1:length(energy)
    junkmat=Spectr(:,:,j);
    Partspec(j)=mean(mean(junkmat(linidxin)));
end
Partspec=Partspec-min(Partspec(beidx)); %% baseline subtract
%% calculate % sp2 based on Hopkins et al.
Tot = [280,310];
CCPeak = [284,287];
totidx=find(energy > Tot(1) & energy < Tot(2));
CCidx=find(energy > CCPeak(1) & energy < CCPeak(2));
Atot=trapz(energy(totidx),Partspec(totidx));
ACC=trapz(energy(CCidx),Partspec(CCidx));
sp2out=ACC./Atot.*8.6;
