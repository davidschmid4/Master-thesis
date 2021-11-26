%% main
classdef main_across < obob_condor_job
    methods
        function run(obj, directory, fs)
            % folder = dir(['/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cocktail_preproc_contin' '/*.mat']);

            % myDir = uigetdir; %gets directory
            addpath('/mnt/obob/obob_ownft');

            obob_init_ft; % Initialize obob_ownft

            addpath('/mnt/obob/staff/jschubert/myfuns'); % must be set after obob_init_ft
            addpath('/mnt/obob/staff/jschubert/toolboxes/mTRF-Toolbox/mtrf');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cluster_jobs');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/');

            % myDir = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cocktail_preproc_contin';
            myDir = directory;
            myFiles = dir(fullfile(myDir,'*.mat')); %gets all mat files in struct

            % for k = 1:length(myFiles)
            all_stim_subjects = {};
            all_resp_subjects = {};

            for k = 1:size(myFiles, 1)
              % get subject id
              baseFileName = myFiles(k).name;
              fullFileName = fullfile(myDir, baseFileName);
              fprintf(1, 'Now reading %s\n', baseFileName);
              %[wavData, Fs] = wavread(fullFileName);
              % all of your actions for filtering and plotting go here
              load(fullFileName);
              
              %ft_selectdata und trials auswählen cfg.trials = all_ss_trials;
              
              all_ss_trials = find(data.trialinfo(:,4) == 0); % ss means single speaker
              cfg = [];
              cfg.trials = all_ss_trials;
              data = ft_selectdata(cfg, data);
              % resampling
              cfg = [];
              % cfg.resamplefs = fs;
              cfg.resamplefs = fs;
              data = ft_resampledata(cfg, data);

              data.trial = cellfun(@(x) transpose(zscore(x,0,2)), data.trial, 'UniformOutput', false);

              stim = {};
              resp = {};
              for i=1:size(data.trial,2)
                stim{1,i} = data.trial{1,i}(:,307:357);
                resp{1,i} = data.trial{1,i}(:,1:306);
              end

              all_stim = vertcat(stim{:});
              all_resp = vertcat(resp{:});

              all_stim_subjects{1,k} = all_stim;
              all_resp_subjects{1,k} = all_resp;
            end

            all_stim_subjects = vertcat(all_stim_subjects{:});
            all_resp_subjects = vertcat(all_resp_subjects{:});

            % split data into training/test sets
            nfold = 6; testTrial = 1;
            [strain,rtrain,stest,rtest] = mTRFpartition(all_stim_subjects,all_resp_subjects,nfold,testTrial);

            % Model hyperparameters
            Dir = -1; % direction of causality
            tmin = 0; % minimum time lag (ms)
            tmax = 250; % maximum time lag (ms)
            lambda = 10.^(-6:2:6); % regularization parameters

            % Run efficient cross-validation
            cv = mTRFcrossval(strain,rtrain,fs,Dir,tmin,tmax,lambda,'zeropad',0,'fast',1);


            % Find optimal regularization value
            [rmax,idx] = max(mean(mean(cv.r),3));
            % Train model
            model = mTRFtrain(strain,rtrain,fs,Dir,tmin,tmax,lambda(idx),'zeropad',0);

            % Test model
            [pred,test] = mTRFpredict(stest,rtest,model,'zeropad',0);
            
            %% save results:
            %------------------------------------------------------------------------
            %fname_2save = obj.get_fname_2save(outdir, subject_id); % saved fileName in outdir
            %
            save('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT_ACROSS/full_model_all.mat', 'test', 'model', '-v7.3');
        end
        % get fname_2save fun
%         function fname_2save = get_fname_2save(obj, outdir, subject_id)
%             fname_2save = fullfile(outdir,['full_model', '.mat']);
%         end % of get_fname_2save fun
    end
end




