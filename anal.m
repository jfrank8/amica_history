EEG = pop_loadset('t2.set');
numprocs = 1;
max_threads = 1;
num_models = 1;
max_iter = 1000;
histstep = 10;

outdir = [ pwd filesep 'amicaouttmp' filesep ];

%[weights,sphere,mods] = runamica15(EEG.data, 'num_models', num_models, ...
%                                   'outdir',outdir, 'numprocs', numprocs,'max_threads',max_threads, 'max_iter',max_iter,'do_history',1,'histstep',histstep);
rvAll=zeros(max_iter/histstep,31);
pmiAll = zeros(1,max_iter/histstep);
pmirAll = zeros(1,max_iter/histstep);
mirAll = zeros(1,max_iter/histstep);

for iter = histstep:histstep:max_iter
   histdir = [outdir filesep 'history' filesep int2str(iter)];
   modout = loadmodout15(histdir);

   EEG = pop_loadset('t2.set');

   % load individual ICA model into EEG structure
   model_index = 1;
   EEG.icawinv = modout.A(:,:,model_index);
   EEG.icaweights = modout.W(:,:,model_index);
   EEG.icasphere = modout.S;
   EEG = eeg_checkset(EEG);
   EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);

   %compute PMI
   % [PMIraw, PMI] = get_pmi(EEG,31)
   % pmir = PMIraw-PMI;
   % pmirAll(iter/histstep) = pmir;
   pmi = get_mi_mean(EEG.icaact);
   pmiRaw = get_mi_mean(EEG.data);
   pmir=pmiRaw-pmi;
   pmirAll(iter/histstep) = pmir;
   pmiAll(iter/histstep) = pmi;

   mir = compute_mir(EEG,31);
   mirAll(iter/histstep) = mir;

   %compute near dipolarity
   EEG = eeg_multifit(EEG);
   allrvRaw = cell2mat( { EEG.dipfit.model.rv } );
   rvAll(iter/histstep,:) = allrvRaw;
   %rvRaw(run,iSubject,:) = allrvRaw



end

figure()
plot(histstep:histstep:max_iter,pmiAll);
xlabel('Number of Steps')
title('PMI')


figure()
plot(histstep:histstep:max_iter,mirAll);
xlabel('Number of Steps')
title('MIR')
%hold on;
%plot(mir_averef);
%legend('raw','ref')
