function [B,spect,baseline] = basel1(A);
% This function evaluates peak integrals by method used in Maria et al. 2004
% But is corrected for what I believe to be double-counting of the
% baseline...
% A is 2D array; column1 = Energy levels; column2 = Absorbance
% outputs are
% Aromatic, Ketonic, Alkyl, Carboxylic, Amide/Alcohol, K, totC, BG

baseline = zeros(size(A,1),1);

% Calculate Background
bg = find(A(:,1) > 278 & A(:,1) < 283);
polyBase = polyfit( A(bg,1), A(bg,2), 0);

% Subtract Background
A(:,2) = A(:,2)-polyval(polyBase,A(:,1));

% Estimate Step
[dummy tnf] = min(abs(294-A(:,1)));
Z = [286,294];
z = find(A(:,1) >= min(Z(:)) & A(:,1) <= max(Z(:)));
baseline(z) = (A(tnf,2)-0)/(294-286)*(A(z,1)-286);

% Potassium
K = [297,298];
k = find(A(:,1) >= K(1) & A(:,1) <= K(2));
baseline(k) = A(k+4,2);
baseline(max(z):min(k)) = baseline(max(z)) + (baseline(min(k))-baseline(max(z)))/...
    (A(min(k),1)-A(max(z),1))*(A(max(z):min(k),1)-A(max(z),1));

% Total Carbon
TC = [301,305];
c = find(A(:,1) >= TC(1) & A(:,1) <= TC(2));
totalc = mean(A(c,2));
baseline(c) = repmat(mean(A(c,2)),length(c),1);
baseline(max(k):min(c)) = baseline(max(k)) + (baseline(min(c))-baseline(max(k)))/...
    (A(min(c),1)-A(max(k),1))*(A(max(k):min(c),1)-A(max(k),1));

baseline = baseline + polyval(polyBase,A(:,1));
% The Rest
r = find(A(:,1) > A(max(c),1));
baseline(r) = A(r,2) + polyval(polyBase,A(r,1));

% Add back to A
A(:,2) = A(:,2)+polyval(polyBase,A(:,1));

% Alkene/Aromatic to Potassium
spect = A(:,2)-baseline;
Z = [284.5,286;
    286.2,287;
    287.4,288.2;
    288.4,289;
    289,289.8];
Z = [Z;K];
B = zeros(size(Z,1)+1,1);
for i=1:size(Z,1)
    B(i) = mean(spect(find(A(:,1) >= Z(i,1) & A(:,1) <= Z(i,2) )));
end

% Total Carbon
B(size(B,1)) = totalc;
% Background
B(size(B,1)+1) = polyBase;
