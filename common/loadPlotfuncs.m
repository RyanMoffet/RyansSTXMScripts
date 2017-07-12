function F = loadPlotfuncs()

F = struct('alignPlot',@alignPlot,'plotRadial',@plotRadial);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function alignPlot(S1,S2)

[cmin{1:2}] = min(abs(S1.eVenergy-288.85));
[fmin{1:2}] = min(abs(S2.eVenergy-710.0));

subplot(2,3,1)
imagesc(S1.XValues,S1.YValues,S1.spectr(:,:,cmin{2})')
axis xy; set(gca,'DataAsp',[1,1,1]);
title('Carbon 288');
subplot(2,3,4)
imagesc(S2.XValues,S2.YValues,S2.spectr(:,:,fmin{2})')
axis xy; set(gca,'DataAsp',[1,1,1]);
title('Iron 710');    
subplot(2,3,2)    
imagesc(S1.XValues,S1.YValues,S1.Total')
axis xy; set(gca,'DataAsp',[1,1,1]);    
title('Total Carbon');       
subplot(2,3,5)
imagesc(S2.XValues,S2.YValues,S2.Total')
axis xy; set(gca,'DataAsp',[1,1,1]);
title('Total Iron');       

%%
subplot(2,3,3)
imagesc(S1.XValues,S1.YValues,S1.coefarr(:,:,4)')
axis xy; set(gca,'DataAsp',[1,1,1]);
title('R(C=O)OH');           

subplot(2,3,6)
imagesc(S2.XValues,S2.YValues,S2.FeIIfrac',[0,1])
axis xy; set(gca,'DataAsp',[1,1,1]);
title('Fe(II) Fraction');   
colorbar;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotRadial(S1,S2,ODfitpars)

specs = {'Total Carbon Intensity','Total Iron Intensity'};
xmax = max([ODfitpars.singleR])*1.5;
for j=1:2,
    S = eval(strcat('S',num2str(j)));
    ca = subplot(2,3,1 + 3*(j-1));
    imagesc(S.XValues,S.YValues,S.Total');
    axis xy; set(ca,'DataAspectRatio',repmat(1,3,1));
    h=colorbar; set(h,'Visible','off');
    xlabel('X (\mum)'); ylabel('Y (\mum)'); title(specs{j});    
    
    ca = subplot(2,3,(2:3) + 3*(j-1));
	plot(ODfitpars(j).radiusFull(:),S.Total(:),'b+');
    line(get(gca,'XLim'),[0,0],'LineS','--','Color',repmat(0.7,3,1));
    line(ODfitpars(j).radius,ODfitpars(j).beta*ODfitpars(j).d,'LineW',3,'Color','g')
    set(ca,'XLim',[0,xmax]);
    xlabel('Radius (\mum)'); ylabel(specs{j});    
end

return