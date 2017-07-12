%% FTMatrixShift

function B=FTMatrixShift(A,dy,dx)

[Ny,Nx]=size(A);
rx = floor(Nx/2)+1; 
fx = ((1:Nx)-rx)/(Nx/2);
ry = floor(Ny/2)+1; 
fy = ((1:Ny)-ry)/(Ny/2);
px = ifftshift(exp(-j*dx*pi*fx))';
py = ifftshift(exp(-j*dy*pi*fy))'; 

[yphase,xphase]=meshgrid(py,px);

yphase=yphase.';
xphase=rot90(xphase);

B=ifft2(fft2(A).*yphase.*xphase);

return