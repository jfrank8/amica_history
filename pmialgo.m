
% nchans = 71;
% PMI = zeros(nchans,nchans,length(algorithms),14);
% PMIraw = zeros(nchans,nchans,14);
%clear mir

EEG = geticadata(dat, algorithms{1});
[MI,T,Hu,hu,Hx] = get_mi(reshape(EEG.data,nchans,EEG.pnts*EEG.trials));
PMIraw = MI;


EEG = geticadata(dat, algorithms{algo});
W = EEG.icaweights;
S = EEG.icasphere;
WS = W*S;
      
      %load('-mat',['ica' int2str(dat) '_72_14_simbec.mat']);
      %WS = W;
      %DATASET = dat;
      %processdat;
      
      

      %if algo == 1
      %    %compute PMI for the raw EEG, we only need to do this once so we
      %    %only do it while processing the first algorithm
      %    [MI,T,Hu,hu,Hx] = get_mi(reshape(EEG.data,nchans,EEG.pnts*EEG.trials))
      %    PMIraw(:,:,dat) = MI;
      %end
 s = WS * reshape(EEG.data,nchans,EEG.pnts*EEG.trials); 
 [MI,T,Hu,hu,Hx] = get_mi(s);
 PMI = MI;


% save results
% WARNING: THIS IS GOING TO ERASE THE EXISTING FILE
%The struct should have: PMI, vPMI, PMIraw
 %copyfile('pmi_new.mat', 'pmi_new_old.mat');
%save('-mat', 'pmi_sept29.mat', 'PMI', 'algorithms');
%save('-mat', 'pmi_new_raw_sept29.mat', 'PMIraw', 'algorithms');