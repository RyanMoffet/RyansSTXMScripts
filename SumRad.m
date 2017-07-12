function [RadOut,StdOut,Sing]=SumRad(RadScan,Std,Nums,SingScans)

RadOut=zeros(size(RadScan{1}));
StdOut=zeros(size(Std{1}));
Num=zeros(1,length(Nums{1}));
% for i=1:length(RadScan) %% should be the number of stacks
%     RadOut=RadOut+RadScan{i};
%         Num=Num+Nums{i};
% end

% Sing=SingScans{1}{1};
% for i=2:length(Num-1)
Sing{1}=[];Sing{2}=[];Sing{3}=[];Sing{4}=[];Sing{5}=[];    
for i=1:length(RadScan)
    for j=1:length(Num)-1
        Sing{j}=[Sing{j},SingScans{i}{j}];
        Sing{j}(Sing{j}<=0)=NaN;
    end
end
for i=1:length(Num) %% should be the number of classes
%     RadOut(:,i)=RadOut(:,i)./Num(i);
    if isempty(Sing{i}) || i==length(RadOut(1,:));
        StdOut(:,i)=zeros(length(RadOut(:,i)),1);
    else
        RadOut(:,i)=nanmean(Sing{i},2);
        StdOut(:,i)=nanstd(Sing{i},0,2);
    end
end