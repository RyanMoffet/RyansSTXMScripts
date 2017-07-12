function [peaks,fit,normspec,coefs,ci,covb,mse,legendstr,fout,b,m]=Nexafs_Decon(spec,par,pre,carbonstruct)
%   Nexafs_Decon's general task is to create a fit of a spectrum using a nonlinear least square fit algorithm,
%   when given a spectrum (spec) and the necessary information (par,pre,carbonstruct) about the fit model(s)!
%   The assumption made is: The spectrum can be fitted by a sum of peaks
%   and steps.
%
%   Input arguments are:
%   "par":   
%   it is a cell containing information about the peaks and steps used in the 
%   fitting algorithm. Mathematical model, position, width, the Lorentzian Fraction
%   (when using a Voigt Fct.) and the assignment of the peak/step to a certain energy
%   excitation/transition are the parameter stored in par.
%   "pre":
%   A cell with two entries: a lower and upper limit for energy. It determines 
%   a region, whose O.D. values will be averaged and then subtracted from the 
%   spectrum. Their default value is "-". So if the user decides, not to create
%   any input at all, they won't be used by "Nexafs_Decon" resp. "Normalization".
%   "carbonstruct":
%   Contains the information at which energy the spectrum was taken (by
%   default it is assumed to be the Carbon K - edge). It further contains
%   values for the constants "b" and "m", used with the asym. Gaussian
%   Fct., modeling an energy dependent width of the Gaussian Fct. (making
%   it asymmetric).
%
%   Output argumets are:
%   "fit":
%   Is the fit itself.
%   "peaks":
%   The individual peaks and steps. 
%   "normspec":
%   A to the maximum O.D. - value mormalized spectrum (subtracted by an
%   offset determined through "pre.").
%   "coefs":
%   Representing the fitted heights of the peaks and the heights and
%   exponential decay coefficients when fitting steps.
%   "ci":
%   The confidence intervals, belonging to the individual "coefs".
%   "covb":
%   The estimated covariance matrix COVB for the fitted coefficients. 
%   "mse":
%   The  estimate mean squared error (mse) of the variance of the error term. 
%   "legendstr":
%   A string cell containing all peak assignments (peaknumber by default,
%   without user input) and two extra fields: "normalized spectrum" and
%   "fit". Is used for the legend of the axes, when the results are
%   plotted.
%   "fout":
%   Cell, that consists of the "coefs" - and "ci" - values sorted and
%   arranged, so it can be displayed in the "Output for fitting process" -
%   table of the GUI.
%   "b":
%   "m";
%   The value for b resp. m used in the nonlinear least square fit. It is an extra
%   output, since these values will only differ from the default values for
%   the Carbon K - edge, if the corresponding checkbox is unchecked. If new
%   values are assigned, but the box is checked again, before starting the
%   fitting algorithm, following will be assumed:The spectrum was taken at
%   the Carbon K - edge after all and the new values are to be ignored.
%   Resulting in using the default values for b and m.



    %load variable spec into fitspec
    fitspec=spec;
    % initialize Fit functions by loading them into F, so they can be used
    % by calling their handle
    F = loadFit_functions();
    % ProcessParameter gives out the legendstr used by the plotting
    % functions of the GUI; the other output is not needed at this level of
    % the fitting process
    [num,position,width,fitmodel,LorFrac,legendstr,b,m]=feval(F.ProcessParameter,par,carbonstruct);
    % calculate a to the maximum value in O.D. normalized version of the
    % spectrum, which has been subtracted by the average O.D. - value of
    % the region determined by variable "pre"
    normspec = feval(F.Normalization,fitspec,pre);
    % actual calculation of the coefficients, their confidence intervals,
    % covariance matrix and mean squared error by function "Peakfit"
    [coefs,ci,covb,mse] = feval(F.Peakfit,normspec(:,1),normspec(:,2),par,carbonstruct);
    %generating the output as a cell for the output table
    fout = feval(F.fit_outout_table,par,carbonstruct,coefs,ci,mse);
    %with the fitted coefficients the single peaks and steps are generated
    peaks = feval(F.Fit_Kernel,coefs,normspec(:,1),par,carbonstruct);
    %as is the finally resulting fit by summing them up, if there was more
    %than one peak/step used
    if num >1
    fit(:,1) = normspec(:,1);
    fit(:,2) = sum(feval(F.Fit_Kernel,coefs,normspec(:,1),par,carbonstruct));
    else
        fit(:,1) = normspec(:,1);
        fit(:,2) = peaks;
    end
    %add the fields "Normalized Spectrum" and "Fit" to the legend string
    sizel=size(legendstr);
    maxleg=sizel(1,2);
    legendstr{maxleg+1}='Normalized Spectrum';
    legendstr{maxleg+2}='Fit';
 
end