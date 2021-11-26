%% main
classdef end_result < obob_condor_job
    methods
        function run(obj, directory, fs)
            fprintf('hi there');
            
            addpath('/mnt/obob/obob_ownft');

            obob_init_ft; % Initialize obob_ownft

            addpath('/mnt/obob/staff/jschubert/myfuns'); % must be set after obob_init_ft
            addpath('/mnt/obob/staff/jschubert/toolboxes/mTRF-Toolbox/mtrf');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cluster_jobs');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/');
            
            myDir = directory;
            myFiles = dir(fullfile(myDir,'*.mat')); %gets all mat files in folder

            
            avg_cor_within = 0;
            avg_cor_across = 0;

            for i = 1:size(myFiles, 1)
                % get subject id
                baseFileName = myFiles(i).name;
                fullFileName = fullfile(myDir, baseFileName);
                fprintf(1, 'Now reading %s\n', baseFileName);

                load(fullFileName, 'test', 'test_across');
                avg_cor_within = avg_cor_within + test.r(1,1);
                avg_cor_across = avg_cor_across + test_across.r(1,1);
            end

            avg_cor_within = avg_cor_within / size(myFiles, 1);
            avg_cor_across = avg_cor_across / size(myFiles, 1);
            
            % save average correlations in file
            save('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT_END_RESULT/end_result_correlations.mat', 'avg_cor_within', 'avg_cor_across', '-v7.3');

        end
    end
end
