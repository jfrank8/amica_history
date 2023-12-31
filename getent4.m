function [Hu,v] = getent4(u,nbins)
% function [Hu,deltau] = getent2(u,nbins)
%
% Calculate nx1 marginal entropies of components of u.
%
% Inputs:
% u Matrix (n by N) of nu time series.
% nbins Number of bins to use in computing pdfs. Default is
% min(100,sqrt(N)).
%
% Outputs:
% Hu Vector n by 1 differential entropies of rows of u.
% v Variance of entropy estimates in Hu
%
[nu,Nu] = size(u);
if nargin &lt; 2 || isempty(nbins)
    nbins = round(3*log2(1+Nu/10));
end
Hu = zeros(nu,1);
deltau = zeros(nu,1);
for i = 1:nu
    umax = max(u(i,:));
    umin = min(u(i,:));
    deltau(i) = (umax-umin)/nbins;
    u(i,:) = 1 + round((nbins - 1) * (u(i,:) - umin) / (umax - umin));
    pmfr = diff([0 find(diff(sort(u(i,:)))) Nu])/Nu;
    Hu(i) = -sum(pmfr.*log(pmfr));
    v(i) = sum(pmfr.*(log(pmfr).^2)) - Hu(i)^2;
    Hu(i) = Hu(i) + (nbins-1)/(2*Nu) + log(deltau(i));
end