function Sout=SootCarboxSizeHist(Sin,ocopt)
%% ocopt is a flag for excluding soot
%% The following fields are appended to Sout:
% % Sout.AvSootCarb=AvSootCarb -- single particle average carbon for soot??
% % Sout.AvTotC=AvTotC; --single particle total carbon
% % Sout.AvCarbox=AvCarbox; ---single particle carboxylic
% % Sout.AvSp2=AvSp2; -- Average single particle Sp2
% % 
%% Run SootCarboxMap to map the Carbox-C=C maps. 
Sin=SootCarboxMap(Sin,0);
% bins=[0.1,0.4,0.7,1,1.3,1.6];
% junkmat=zeros(size(S.spectr(:,:,1)));
if isempty(Sin.SootCarbox)
    Sout=Sin;
    Sout.AvSootCarb=zeros(size(Sin.Size));
    Sout.AvSootCarb(Sout.AvSootCarb==0)=NaN;
    Sout.AvTotC=zeros(size(Sin.Size));
    Sout.AvTotC(Sout.AvTotC==0)=NaN;  
    Sout.AvSp2=zeros(size(Sin.Size));
    Sout.AvSp2(Sout.AvSp2==0)=NaN;
    Sout.AvCarbox=zeros(size(Sin.Size));
    Sout.AvCarbox(Sout.AvCarbox==0)=NaN;
    return
end

AvSootCarb=zeros(1,max(max(Sin.LabelMat)));
AvTotC=zeros(1,max(max(Sin.LabelMat)));
AvSp2=zeros(1,max(max(Sin.LabelMat)));
AvCarbox=zeros(1,max(max(Sin.LabelMat)));

%% Find regions having OC if OC is to be excluded from particle peak
%% averages
if ocopt==1
    [ks,ls]=find(Sin.Maps(:,:,3)>0);
    locs=sub2ind(size(Sin.LabelMat),ks,ls);
%     tempmat=zeros(size(Sin.sp2));
%     tempmat(locs)=1;
%     figure,imagesc(tempmat);
%     tempmat=zeros(size(Sin.sp2));
end

%% average raw maps (TotC, %sp2, Carbox, SootCarbox) over particle regions
for i = 1:max(max(Sin.LabelMat)) %% loop over all particles in stack
    [k,l]=find(Sin.LabelMat==i);
    loc=sub2ind(size(Sin.LabelMat),k,l); %% find particle region (all components included)
    if ocopt==1
        loc=setdiff(loc,locs);
        tempmat(loc)=1;
    end
    for j=1:length(Sin.spectr(1,1,:))
        junkmat=Sin.spectr(:,:,j);
        Partspec(j,i)=mean(mean(junkmat(loc)));
    end

    %     junkmat=Spectr(:,:,j);
    AvSootCarb(i)=nanmean(nanmean(Sin.SootCarbox(loc)));
    AvTotC(i)=nanmean(nanmean(Sin.TotC(loc)));
    AvSp2(i)=(Partspec(2,i)-Partspec(1,i))/(Partspec(end,i)-Partspec(1,i))*(0.4512/0.8656);
    AvCarbox(i)=nanmean(nanmean(Sin.carbox(loc)));
    clear k l loc;
end
AvSp2(AvSp2<0)=0;
AvSp2(AvSp2>1)=1;
% figure,imagesc(tempmat);
% figure, plot(Sin.Size,AvSootCarb,'.')
Sout=Sin;
Sout.AvSootCarb=AvSootCarb;
Sout.AvTotC=AvTotC;
Sout.AvCarbox=AvCarbox;
Sout.AvSp2=AvSp2;
return