function [PMIraw, PMI] = get_pmi(EEG,nchans)
%EEG = geticadata(dat, algorithms{1});
[MI,T,Hu,hu,Hx] = get_mi(reshape(EEG.data,nchans,EEG.pnts*EEG.trials));
PMIraw = MI;


%EEG = geticadata(dat, algorithms{algo});
W = EEG.icaweights;
S = EEG.icasphere;
WS = W*S;
      
s = WS * reshape(EEG.data,nchans,EEG.pnts*EEG.trials); 
[MI,T,Hu,hu,Hx] = get_mi(s);
PMI = MI;
end