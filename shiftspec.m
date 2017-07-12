function shiftspec(Snew,shift)


Snew.eVenergy=Snew.eVenergy+shift;

save(sprintf('%s%s','F',Snew.particle))

load(sprintf('%s%s%s','F',Snew.particle,'.mat'))

return

