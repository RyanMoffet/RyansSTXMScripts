function F = loadFeFunctions()

F = struct('read_refspec',@read_refspec,'Fefits',@Fefits,'fe2fracByPixel',@fe2fracByPixel,...
    'dofit',@dofit);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FeCl2,FeCl3] = read_refspec()

%% read spectra
FeCl2 = textread('C:\Documents and Settings\takahama\My Documents\UCSD\projects\STXM\reports\Iron_Redox\refspec\FeCl2_smoothed.txt');
c = {}; [c{1:2}] = unique(FeCl2(:,1)); FeCl2 = FeCl2(c{2},:);
FeCl3 = textread('C:\Documents and Settings\takahama\My Documents\UCSD\projects\STXM\reports\Iron_Redox\refspec\FeCl3_smoothed.txt');
c = {}; [c{1:2}] = unique(FeCl3(:,1)); FeCl3 = FeCl3(c{2},:);
clear c;

%% scale spectra
FeCl2(:,2) = FeCl2(:,2) - mean(FeCl2(find(FeCl2(:,1) < 704.5),2));
FeCl2(:,2) = FeCl2(:,2) / max(FeCl2(:,2));
FeCl3(:,2) = FeCl3(:,2) - mean(FeCl3(find(FeCl3(:,1) < 704.5),2));
FeCl3(:,2) = FeCl3(:,2) / max(FeCl3(:,2));

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FeIIfrac,aveFrac] = Fefits(S,FeCl2,FeCl3,badEnergies)

%% Optimize by pixel
C = [repmat(1,length(S.eVenergy),1),...
        interp1(FeCl2(:,1),FeCl2(:,2),S.eVenergy),...
        interp1(FeCl3(:,1),FeCl3(:,2),S.eVenergy)];
coeffs = fe2fracByPixel(C,S,badEnergies);
FeIIfrac= coeffs(:,:,2)./(coeffs(:,:,2)+coeffs(:,:,3));   

%% Average Spec
d = S.aveSpec;
out = dofit(S.eVenergy,C,d,badEnergies');
b = out{1};
aveFrac = [b(1),b(2)/(b(2)+b(3))];

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function coeffs = fe2fracByPixel(C,S,badEnergies)

coeffs = repmat(NaN,[size(S.spectr,1),size(S.spectr,2),3]); % empty
%% Loop by pixel
for i=1:size(S.spectr,1),
    for j=1:size(S.spectr,2),
        %% skip if missing or below threhold, continue
        if ~S.Masked(i,j)
            disp([num2str(i),' ',num2str(j),' ','continue']);
            continue
        end
        %%
        %% try stackfit
        d = reshape(S.spectr(i,j,:),[],1);
        try,
            out = dofit(S.eVenergy,C,d,badEnergies');
            coeffs(i,j,1:3) = out{1};
            disp([num2str(i),' ',num2str(j),' ','fitted']);                
        catch,
            disp([num2str(i),' ',num2str(j),' ','failed']);
        end
        %%
    end
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = dofit(Energies,C,d,bad)
% dofit(Energies,C,d,b)

d(find(isinf(abs(d)))) = NaN;
for rm = bad,
    c = {};
	[c{1:2}] = min(abs(Energies-rm));
	d(c{2}) = NaN;
end
subset = find(all(~isnan(C)')' & ~isnan(d));
out = {};
[out{1:6}] = lsqlin(C(subset,:),d(subset),[],[],[],[],[0 0 0],[]);
