function fileName = makebidsfile( parentPath, bidsRepo, subject, bidsSession, bidsTask, bidsRun)

if ~isempty(bidsSession)
    if ~isempty(bidsRun)
        fileName = fullfile(parentPath, bidsRepo, subject, bidsSession, 'eeg', [ subject '_' bidsSession '_' bidsTask '_run-' bidsRun '_eeg.set' ]);
    else
        fileName = fullfile(parentPath, bidsRepo, subject, bidsSession, 'eeg', [ subject '_' bidsSession '_' bidsTask '_eeg.set' ]);
    end
else
    if ~isempty(bidsRun)
        fileName = fullfile(parentPath, bidsRepo, subject, 'eeg', [ subject '_' bidsTask '_run-' bidsRun '_eeg.set' ]);
    else
        fileName = fullfile(parentPath, bidsRepo, subject, 'eeg', [ subject '_' bidsTask '_eeg.set' ]);
    end
end