function [mir] = compute_mir(EEG, nchans)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes herex

W = EEG.icaweights;
S = EEG.icasphere;
WS = W*S;

h0 = getent2(reshape(EEG.data,nchans,EEG.pnts*EEG.trials));
s = WS * reshape(EEG.data,nchans,EEG.pnts*EEG.trials); 
h = getent2(s);

mir = sum(h0) - sum(h) + sum(log(abs(eig(WS))));

end