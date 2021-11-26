%% main
classdef e < obob_condor_job

myDir = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT';
myFiles = dir(fullfile(myDir,'*.mat')); %gets all mat files in folder

avg_cor = 0;

for i = 1:size(myFiles, 1)
    % get subject id
    baseFileName = myFiles(i).name;
    fullFileName = fullfile(myDir, baseFileName);
    % fprintf(1, 'Now reading %s\n', baseFileName);

    load(fullFileName, 'test');
    avg_cor = avg_cor + test.r(1,1);
end

avg_cor = avg_cor / size(myFiles, 1);


