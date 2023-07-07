clear
bidsRepo  = 'ds002680';
bidsTask  = 'task-gonogo';
bidsSess  = 'ses-01';


%% ---------------
%% End of settings
%% end of set
%% ---------------

tmpp = fileparts(which('dipplot'));
rmpath(tmpp);
tmpp = fileparts(which('processdat'));
addpath(fullfile(tmpp, 'dipfit1.02'));
addpath(fullfile(tmpp, 'dipfit1.02', 'copyprivate'));

% add necessary path (your path might be different
if ~exist('eeg_checkset.m', 'file')
    addpath('~/eeglab');
    eeglab;Gwenevere
end

participants = readtable(fullfile( bidsRepo, 'participants.tsv'), 'filetype', 'delimitedtext');
nParticipants = size(participants,1);

%EEG = pop_loadset('t2.set');
numprocs = 1;
max_threads = 1;
%num_models = 1;
max_iter = 1000;
histstep = 10;
bidsRun = '1'
% 
% for iSubject = 1:nParticipants % switch to parfor
%     outdir = [ pwd filesep 'amicaouttmp' iSubject filesep ];
% end

%[weights,sphere,mods] = runamica15(EEG.data, ...
%                                   'outdir',outdir, 'numprocs', numprocs,'max_threads',max_threads, 'max_iter',max_iter,'do_history',1,'histstep',histstep);
rvAll=zeros(nParticipants,max_iter/histstep,31);
pmiAll = zeros(nParticipants,max_iter/histstep);
pmirAll = zeros(nParticipants,max_iter/histstep);
pmiRawAll = zeros(nParticipants,max_iter/histstep);
mirAll = zeros(nParticipants,max_iter/histstep);

for iSubject = 1:nParticipants % switch to parfor
    outdir = [ pwd filesep 'amicaouttmp' int2str(iSubject) filesep ];
    subject = participants{iSubject,1}{1};
    fileName = makebidsfile( '.', bidsRepo, subject, bidsSess, bidsTask, bidsRun); %what about run?
    fprintf('Processing file %s\n', fileName);
    filePath = fileparts(fileName);
    
    % load data
    EEG = pop_loadset(fileName);
    EEG = pop_select(EEG, 'point', [0 10000]);
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5); % something to look into, how filtering affect ICA
    %[weights,sphere,mods] = runamica15(EEG.data, ...
    %                                'outdir',outdir, 'numprocs', numprocs,'max_threads',max_threads, 'max_iter',max_iter,'do_history',1,'histstep',histstep);        
        % run ICA on data
    EEG = pop_runamica(EEG,'outdir',outdir, 'numprocs', numprocs,'max_threads',max_threads, 'max_iter',max_iter,'do_history',1,'histstep',histstep)
    EEG.icachansind = [1:EEG.nbchan]
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:)
    %oldicaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    
    for iter = histstep:histstep:max_iter

      
       
       histdir = [outdir filesep 'history' filesep int2str(iter)];
       %modout = loadmodout15(histdir);
    
       EEG = pop_loadset(fileName);
       EEG = pop_select(EEG, 'point', [0 10000]);
       EEG = pop_eegfiltnew(EEG, 'locutoff',0.5); % something to look into, how filtering affect ICA
       EEG = eeg_loadamica(EEG,histdir)
       % load individual ICA model into EEG structure
       %model_index = 1;
       %EEG.icawinv = modout.A(:,:,model_index);
       %EEG.icaweights = modout.W(:,:,model_index);
       %EEG.icasphere = modout.S;
       EEG.icachansind = [1:EEG.nbchan]
       EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    
       %compute PMI
       % [PMIraw, PMI] = get_pmi(EEG,31)
       % pmir = PMIraw-PMI;
       % pmirAll(iter/histstep) = pmir;
       pmi = get_mi_mean(EEG.icaact);
       pmiRaw = get_mi_mean(EEG.data);
       pmir=pmi/pmiRaw * 100;
       pmiRawAll(iSubject,iter/histstep) = pmiRaw;
       pmirAll(iSubject,iter/histstep) = pmir;
       pmiAll(iSubject,iter/histstep) = pmi;
    
       mir = compute_mir(EEG,31);
       mirAll(iSubject,iter/histstep) = mir;
    
       %compute near dipolarity
       EEG = eeg_multifit(EEG);
       allrvRaw = cell2mat( { EEG.dipfit.model.rv } );
       rvAll(iSubject,iter/histstep,:) = allrvRaw;
       %rvRaw(run,iSubject,:) = allrvRaw
    
    
    
    end
end

save('hisres.mat','pmirAll','mirAll','rvAll')
load('hisres.mat');

figure()
plot(histstep:histstep:max_iter,mean(pmirAll),'-ok');
xlabel('Number of Steps')
ylabel('Remnant Pairwise Mutual Information (%)')
title('Remnant PMI')

figure()
errorbar(histstep:histstep:max_iter,mean(pmirAll),std(pmirAll));
xlabel('Number of Steps')
ylabel('Remnant Pairwise Mutual Information (%)')
title('Remnant PMI')


figure()
plot(histstep:histstep:max_iter,(mean(mirAll)*1.4427*250)/1000,'-ok');
xlabel('Number of Steps')
ylabel('Mutual Information Reduction (kbits/sec)')
title('MIR')

figure()
errorbar(histstep:histstep:max_iter,(mean(mirAll)*1.4427*250)/1000,std(mirAll));
xlabel('Number of Steps')
ylabel('Mutual Information Reduction (kbits/sec)')
title('MIR')

meanRv = transpose(squeeze(mean(rvAll)));
figure('position', [10   10   1000   1000]);
hh = semilogy(sort(meanRv(:,1)), 'w'); hold on;
delete(hh);
c = flip(autumn(max_iter/histstep),1);
for i = histstep:histstep:max_iter
    h = semilogy(linspace(1,100,length(sort(meanRv(:,(i/histstep))))), sort(meanRv(:,(i/histstep))),'Color',c(i/histstep,:)); hold on;
end
view([90 270]);
xlabel('Percent of ICA components');
ylabel('Dipole model residual variance (%)');
set(gca, 'ylim', [0.004, 1]);
set(gca, 'xlim', [0 100]);
set(gca, 'ytick', [0.01 0.05 0.1 0.2 1], 'yticklabel', [1 5 10 20 100]);
set(gcf, 'paperpositionmode', 'auto');
setfont(gcf, 'fontsize', 20);
%set(lh, 'position', [0.1598 0.2119 0.1670 0.7141]);
title('dipolarity')
ylabel('Dipole model residual variance(%)')
xlabel('Percent of ICA Componets')


%hold on;
%plot(mir_averef);
%legend('raw','ref')
