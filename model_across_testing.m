%% main
classdef model_across_testing < obob_condor_job
    methods
        function run(obj, subject_id, preproc_dir, outdir, fs, across_model)

            addpath('/mnt/obob/obob_ownft');

            obob_init_ft; % Initialize obob_ownft

            addpath('/mnt/obob/staff/jschubert/myfuns'); % must be set after obob_init_ft
            addpath('/mnt/obob/staff/jschubert/toolboxes/mTRF-Toolbox/mtrf');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cluster_jobs');
            addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/');
            
            %% check whether folder exists:
            if ~exist(outdir,'dir')
                mkdir(outdir);
            end
            
            % load subject data
            load(fullfile(preproc_dir, [subject_id, '.mat']), 'data')
            
            % only include single speaker trials
            all_ss_trials = find(data.trialinfo(:,4) == 0); % ss means single speaker
            cfg = [];
            cfg.trials = all_ss_trials;
            data = ft_selectdata(cfg, data);
            
            % resampling
            cfg = [];
            cfg.resamplefs = fs;
            data = ft_resampledata(cfg, data);
            
            data.trial = cellfun(@(x) transpose(zscore(x,0,2)), data.trial, 'UniformOutput', false);
            %fs = 64;

            stim = {};
            resp = {};
            for i=1:size(data.trial,2)
                stim{1,i} = data.trial{1,i}(:,307:357);
                resp{1,i} = data.trial{1,i}(:,1:306);
            end

            all_stim = vertcat(stim{:});
            all_resp = vertcat(resp{:});

            % split data into training/test sets
            nfold = 6; testTrial = 1;
            [strain,rtrain,stest,rtest] = mTRFpartition(all_stim,all_resp,nfold,testTrial);


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

            % Test model with across_trained model
            [pred_across,test_across] = mTRFpredict(all_stim,all_resp,across_model,'zeropad',0);
            
            
            %% save results:
            %------------------------------------------------------------------------
            %fname_2save = obj.get_fname_2save(outdir, subject_id); % saved fileName in outdir
            %
            fname_2save = obj.get_fname_2save(outdir, subject_id); % saved fileName in outdir
            %
            save(fname_2save, 'test', 'model', 'pred', 'pred_across', 'test_across', '-v7.3');        
        end
        % get fname_2save fun
        function fname_2save = get_fname_2save(obj, outdir, subject_id)
            fname_2save = fullfile(outdir,[subject_id, '.mat']);
        end % of get_fname_2save fun
    end 
end