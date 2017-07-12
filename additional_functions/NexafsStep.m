function StepFunction = NexafsStep(e,p,m,d)

%% Plots a step function for fitting NEXAFS data
%% e is a vector of energy values
%% p is the position of the inflection point
g = 1;
idx1 = find(e <= (p + g));
idx2 = find(e > (p + g)); 

SF1 = m.*(0.5 + 0.5.*erf((e(idx1)-p)./(g./1.665)));
SF2 = (m*(0.5 + 0.5.*erf((e(idx2)-p)./(g./1.665)))).*...
            exp(-d.*(e(idx2)-p-g));

StepFunction = [SF1;SF2];       