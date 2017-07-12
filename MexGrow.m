function MexGrow(Dp,DpMax,dt)

imax=500000;
telapse=0;
i=1;
Dplot=zeros(imax,1);
Dplot(1)=Dp;
while Dp<=DpMax
    i=i+1;
    telapse=telapse+dt;
    Dp=Dp+0.01e-6/fuchs(0.01e-6)*fuchs(Dp)*dt;
    Dplot(i)=Dp;
    if i>imax
        sprintf('imax exceeded')
        break
    end
end

Dfin=Dplot(Dplot~=0);
time=0:dt:telapse;
plot(time,Dfin(1:length(time)).*1e6)
telapse
i

