%% FTMatrixShift

function B=FTMatrixShift(A,dy,dx)

[Ny,Nx]=size(A);
rx = floor(Nx/2)+1; 
fx = ((1:Nx)-rx)/(Nx/2);
ry = floor(Ny/2)+1; 
fy = ((1:Ny)-ry)/(Ny/2);
px = ifftshift(exp(-j*dx*pi*fx))';
py = ifftshift(exp(-j*dy*pi*fy))'; 

%y-shift:

B=fft(A);

for k=1:Ny
    
    B(k,:)=B(k,:)*py(k,1);
    
end


%x-shift:

B=(ifft(B)).';
B=fft(B);

for k=1:Nx
    
    B(k,:)=B(k,:)*px(k,1);
    
end

B=(ifft(B)).';

return