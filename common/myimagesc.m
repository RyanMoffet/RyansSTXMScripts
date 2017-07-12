function myimagesc(S,X),
% function myimagesc(S,X)

imagesc(S.XValues,S.YValues,X');
set(gca,'DataAspectRatio',[1,1,1],'YDir','normal');

return