function F = loadFit_Models() 
%   "loadFit_Models" loads 6 function handles into the struct F. These
%   handles describe the 6 possible mathematical models you can use to
%   describe a peak or step. You can use these handles with the
%   "feval(F.handlename)" - function of matlab. The 6 function available
%   are: Gaussian Fct.; Lorentzian Fct; an approximate Voigt Fct.;
%   Asymmetric Gaussian Fct.; Gaussian Shaped Step; Lorentzian Shaped Step.
%   
%   The formulas describing the models were taken from the book "NEXAFS
%   Spectroscopy" by Joachim Stoehr, chapter 7: "Analysis of K-Shell
%   Excitation Spectra by Curve Fitting".


F = struct('Gaussian_Fct',@Gaussian_Fct,'Lorentzian_Fct',@Lorentzian_Fct,'Voigt_Fct',@Voigt_Fct,...
    'Asym_Gaussian_Fct',@Asym_Gaussian_Fct,'Gaussian_Shaped_Step',@Gaussian_Shaped_Step,...
    'Lorentzian_Shaped_Step',@Lorentzian_Shaped_Step);

return

%--------------------------------------------------------------------------

function g = Gaussian_Fct(H,x,pos,wid)


g = abs(H)*exp(-((x-pos)./(0.6006*wid)).^2);


%--------------------------------------------------------------------------

function l = Lorentzian_Fct(H,x,pos,wid)


l = abs(H)*(wid/2)^2./((x-pos).^2+(wid/2)^2);

%--------------------------------------------------------------------------

function v = Voigt_Fct(H,n,x,pos,wid)


v = abs(H)*(abs(n)*((wid/2)^2./((x-pos).^2+(wid/2)^2))+(1-abs(n))*(exp(-((x-pos)./(0.6006.*wid)).^2)));

%--------------------------------------------------------------------------

function g = Asym_Gaussian_Fct(H,x,pos,b,m)


gam = x.*m +b;

g = abs(H)*exp(-0.5*((x-pos)./(gam/2.355)).^2); 

%--------------------------------------------------------------------------

function StepFunction = Gaussian_Shaped_Step(H,d,e,p,wid)


if isempty(wid)
    wid = 1;
end

idx1 = find(e <= (p + wid));
idx2 = find(e > (p + wid)); 

SF1 = abs(H)*(0.5 + 0.5*erf((e(idx1)-p)./(wid/1.665)));
SF2 = (abs(H)*(0.5 + 0.5*erf((e(idx2)-p)./(wid/1.665)))).*...
            exp(-d*(e(idx2)-p-wid));

StepFunction = [SF1;SF2];       

%--------------------------------------------------------------------------

function StepFunction = Lorentzian_Shaped_Step(H,d,e,p,wid)


if isempty(wid)
    wid = 1;
end

idx1 = find(e <= (p + wid));
idx2 = find(e > (p + wid)); 

SF1 = abs(H)*(0.5 + (1/pi).*atan((e(idx1)-p)./(wid/1.665)));
SF2 = (abs(H)*(0.5 + (1/pi).*atan((e(idx2)-p)./(wid/1.665)))).*...
            exp(-d*(e(idx2)-p-wid));

StepFunction = [SF1;SF2];       

