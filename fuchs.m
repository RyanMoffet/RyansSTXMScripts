function phi=fuchs(Dp)

lam=0.066e-6;

phi=(2*lam+Dp)./(Dp+5.33*(lam^2./Dp)+3.42*lam);