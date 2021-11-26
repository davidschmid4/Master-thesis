load('/mnt/obob/staff/dschmidt/Masterarbeit/mTRF_Masterarbeit/cocktail_preproc_contin/19811015krln.mat');

all_ss_trials = find(data.trialinfo(:,4) == 0); % ss means single speaker
cfg = [];
cfg.trials = all_ss_trials;
data = ft_selectdata(cfg, data);
% resampling
cfg = [];
% cfg.resamplefs = fs;
cfg.resamplefs = 100;
data = ft_resampledata(cfg, data);

data.trial = cellfun(@(x) transpose(zscore(x,0,2)), data.trial, 'UniformOutput', false);

stim = {};
resp = {};
% for i=1:size(data.trial,2)
for i=1:2
    stim{1,i} = data.trial{1,i}(:,307:357);
    resp{1,i} = data.trial{1,i}(:,1:306);
end

all_stim = vertcat(stim{:});
all_resp = vertcat(resp{:});

              

% apply MCCA
test_x = data.trial{1,1}(:,1:306); % concatenate channelwise
test_C=test_x'*test_x;
[test_A,test_score,test_AA]=nt_mcca(test_C,306);
test_z=test_x*test_A;

figure(2); clf
subplot 121;
plot(test_score, '.-');
title('variance per SC');
ylabel('variance'); xlabel('SC');
subplot 122;
plot(test_z(:,1)); set(gca,'ytick',[]);
title('recovered (SC 1)');  xlabel('sample')
% Fig2: MCCA recovers the target.

corrcoef(test_z(:,1), data.trial{1,1}(:,330))
              
              
              