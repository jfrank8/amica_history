% run recenter channels before running this script to 
% adjust the BIDS locations from the downloaded datasets

clear
bidsRepo  = 'ds002680';
bidsTask  = 'task-gonogo';
bidsSess  = 'ses-01';
bidsRun = '1';
parallel  = 3; % expanse

try
    parpool(parallel);
catch
end

%% ---------------
%% End of settings
%% ---------------

% add necessary path (your path might be different
if ~exist('eeg_checkset.m', 'file')
    addpath('~/eeglab');
    eeglab;
end

participants = readtable(fullfile( bidsRepo, 'participants.tsv'), 'filetype', 'delimitedtext');
nParticipants = size(participants,1);
pmi_raw    = zeros(1,nParticipants);
pmi_averef = zeros(1,nParticipants);

for iSubject = 1:nParticipants % switch to parfor

    subject = participants{iSubject,1}{1};
    fileName = makebidsfile( '.', bidsRepo, subject, bidsSess, bidsTask, bidsRun); %what about run?
    fprintf('Processing file %s\n', fileName);
    filePath = fileparts(fileName);

    % load data
    EEG = pop_loadset(fileName);
    EEG = pop_select(EEG, 'point', [0 10000]);
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5); % something to look into, how filtering affect ICA

    % add reference CZ
    EEGaveref = pop_chanedit(EEG, 'append',31,'changefield',{32,'labels','Cz'});
    EEGaveref = pop_chanedit(EEGaveref, 'setref',{'1:32','Cz'});
    EEGaveref = pop_reref( EEGaveref, [],'refloc',struct('labels',{'Cz'},'type',{''},'unit',{[]},'X',{0},'Y',{0},'Z',{85},'sph_theta',{0},'sph_phi',{90},'sph_radius',{[]},'theta',{0},'radius',{0},'ref',{'Cz'},'urchan',{[]},'label',{''},'datachan',{0}));

    options = { 'maxsteps', 10, 'extended', 1, 'lrate', 1e-5 };
    %options = { 'extended', 1 };
    
    % run ICA on data
    EEG = pop_runica(EEG, options{:});
    pmi_raw(iSubject) = get_mi_mean(EEG.icaact); 

    % run ICA on average ref data
    EEGaveref = pop_runica(EEGaveref, 'pca', -1, options{:});
    pmi_averef(iSubject) = get_mi_mean(EEGaveref.icaact);    
end

printvar(pmi_raw);
printvar(pmi_averef);
save('-mat', [ 'ref_' datestr(now, 30) '.mat'], 'pmi_raw', 'pmi_averef');


