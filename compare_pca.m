% run recenter channels before running this script to 
% adjust the BIDS locations from the downloaded datasets

clear
bidsRepo = 'ds003061';
bidsTask      = 'task-P300';
bidsSess      = '';
icaType  = '';
parallel = 39;

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
pca_single1 = zeros(1, nParticipants*3);
pca_single2 = zeros(1, nParticipants*3);
pca_double1 = zeros(1, nParticipants*3);
pca_double2 = zeros(1, nParticipants*3);
mir_single  = zeros(1, nParticipants*3);
mir_double  = zeros(1, nParticipants*3);
mir_double2  = zeros(1, nParticipants*3);
pmi_single  = zeros(1, nParticipants*3);
pmi_double  = zeros(1, nParticipants*3);
pmi_double2  = zeros(1, nParticipants*3);
parfor iSubjectRun = 1:nParticipants*3
%for iSubjectRun = 1

    iSubject = floor((iSubjectRun-1)/3)+1;
    iRun     = mod(iSubjectRun-1,3)+1;

    subject = participants{iSubject,1}{1};
    fileName = makebidsfile( '.', bidsRepo, subject, bidsSess, bidsTask, num2str(iRun));
    fprintf('Processing file %s\n', fileName);
    filePath = fileparts(fileName);

    EEG = pop_loadset(fileName);

    % preprocess data
    removeChans = {'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8','GSR1','GSR2','Erg1','Erg2','Resp','Plet','Temp','061','062','063','064'};
    EEG = pop_loadset('filename',fileName);
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5);  
    EEG = pop_select( EEG, 'nochannel',removeChans); % list here channels to ignore

    % rereference
    EEG = pop_reref(EEG, []);
    [pc,eigvec,sv1] = runpca(single(EEG.data)); 
    [pc,eigvec,sv2] = runpca(double(EEG.data)); 
    pca_single1(iSubjectRun) = sv1(end,end);
    pca_double1(iSubjectRun) = sv2(end,end);
    pca_single2(iSubjectRun) = lowest_eig(single(EEG.data));
    pca_double2(iSubjectRun) = lowest_eig(double(EEG.data));

    options = { 'maxsteps', 10, 'extended', 1, 'lrate', 1e-5 };
    %options = { 'extended', 1 };
    
    % run ICA single precision on PCA-1 EEG matrix average referenced
    % then reconstruct the full data
    [tmpdata,eigvec] = runpca(double(EEG.data));
    [W,S] = runica_single(single(tmpdata(1:end-1,:)), options{:});
    icawinv = eigvec(:,1:end-1) * pinv(W * S); % Jason: W = W*S; icaweights = [icaweights;eigvec(:,end)']; icawinv = pinv(icaweights);
                                               % Jason: convergence, PCA further away from solution so need more steps, check convergence
    %icawinv(:,end+1) = eigvec(:,end);
    icaweights = pinv(icawinv);
    icaweights(:,end) = []; % cannot remove channel
    mir_single(iSubjectRun) = getmir(icaweights, double(EEG.data(1:end-1,:)));
    pmi_single(iSubjectRun) = get_mi_mean(icaweights*double(EEG.data(1:end-1,:)));

    % same as above double precision
    [tmpdata,eigvec] = runpca(double(EEG.data));
    [W,S] = runica(single(tmpdata(1:end-1,:)), options{:});
    icawinv = eigvec(:,1:end-1) * pinv(W * S);
    %icawinv(:,end+1) = eigvec(:,end);
    icaweights = pinv(icawinv);
    icaweights(:,end) = [];
    mir_double(iSubjectRun) = getmir(icaweights, double(EEG.data(1:end-1,:)));
    pmi_double(iSubjectRun) = get_mi_mean(icaweights*double(EEG.data(1:end-1,:)));

    % run ICA double precision on EEG.data dim -1 
    [tmpdata,eigvec] = runpca(double(EEG.data(1:end-1,:))); % PCA for symmetry with other approaches
    [W,S] = runica(double(tmpdata), options{:});
    icawinv = eigvec * pinv(W * S);
    icaweights = pinv(icawinv);
    mir_double2(iSubjectRun) = getmir(icaweights, double(EEG.data(1:end-1,:)));
    pmi_double2(iSubjectRun) = get_mi_mean(icaweights*double(EEG.data(1:end-1,:)));

    % run ICA double precision on EEG.data dim -1 
    [W,S] = runica(double(EEG.data(1:end-1,:)), options{:});
    icawinv = pinv(W * S);
    icaweights = pinv(icawinv);
    mir_double3(iSubjectRun) = getmir(icaweights, double(EEG.data(1:end-1,:)));
    pmi_double3(iSubjectRun) = get_mi_mean(icaweights*double(EEG.data(1:end-1,:)));
end

printvar(pca_single1);
printvar(pca_single2);
printvar(pca_double1);
printvar(pca_double2);
printvar(mir_single);
printvar(mir_double);
printvar(mir_double2);
printvar(mir_double3);
printvar(pmi_single);
printvar(pmi_double);
printvar(pmi_double2);
printvar(pmi_double3);
save('-mat', [ 'pca_' icaType '_' datestr(now, 30) '.mat'], 'pca_single1', 'pca_single2', 'pca_double1', 'pca_double2', 'mir_single', 'mir_double', 'mir_double2', 'mir_double3', 'pmi_single', 'pmi_double', 'pmi_double2', 'pmi_double3');


