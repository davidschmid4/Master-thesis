%% RUNNING TONES DECODING ON CLUSTER (all_subjects):
% add paths & init packages:
addpath('/mnt/obob/obob_ownft');

cfg = [];
cfg.package.hnc_condor = true;
obob_init_ft(cfg); % Initialize obob_ownft

addpath('/mnt/obob/staff/jschubert/myfuns'); % must be set after obob_init_ft
addpath('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cluster_jobs');

% data paths
OUTDIR = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT_TEST_ACROSS_MODEL';
PREPROC_DIR = '/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cocktail_preproc_contin/';
FS=100;

% create struct for cluster job
cfg = [];
cfg.mem = '20G'; % per subject
cfg.adjust_mem = true;
condor_struct = obob_condor_create(cfg);

% get subjects
all_subjects = js_getsubjectsfrom(PREPROC_DIR);

% get across model trained on all subjects
load('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/OUTPUT_ACROSS/full_model_all.mat', 'model');
across_model = model;

%%%% send to cluster
condor_struct = obob_condor_addjob_cell(condor_struct, 'model_across_testing', ...
all_subjects, PREPROC_DIR, OUTDIR, FS, across_model);
obob_condor_submit(condor_struct);

