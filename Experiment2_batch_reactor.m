% Experiment 2: observational noise (UID vs. UID + SIM)

% Model: batch_reactor

%% select model
clear; clc; close all;                               % clear workspace
load('analysis_mode.mat')                            % check if analysis mode is on
rng(1)                                               % set random number generator seed for reproducibility
sysUID = dynamical_system('batch_reactor', 'UID');   % select example model and identifiability status

disp('Running experiment 2 - batch_reactor')         % display running message
%% define classification problem and set data generation parameters

% ---------------- CLASSIFICATION PROBLEM -------------------------------->
b1 = 5/4;
b2 = 30;
mum = 0.5;
Ks = 3;
Y = 0.6;
Kd = 0.05;
dataGenPars.parClass.C0.mu = [b1, b2, mum, Ks, Y, Kd];
dataGenPars.parClass.C1.mu = [b1, b2, mum, Ks, 0.8 * Y, Kd];

% set covariance matrix for intra-class variation
dataGenPars.parClass.C0.Sigma = diag([10^-1, 10^-0, 10^-2, 10^-1, 10^-2, 10^-3].^2);
dataGenPars.parClass.C1.Sigma = diag([10^-1, 10^-0, 10^-2, 10^-1, 10^-2, 10^-3].^2);
% ------------------------------------------------------------------------<

% ---------------- DATA GENERATION PARAMETERS ---------------------------->

% Select number of training and test examples to produce
dataGenPars.numExamples.train = 200;            % fixed for this experiment
dataGenPars.numExamples.test = 400;

% Set times at which to evaluate analytic solution
dataGenPars.obsMode.t = 0:1:12;

% set vector of std. of observational noise (Gaussian) added to timeseries
dataGenPars.sigmaObsVec = [0.1, 1:5];                 
% ------------------------------------------------------------------------<
%% generate timeseries and MAP estimates for UID model for different noise levels

% generate data for UID model
t1 = tic;
dataUID = genDataExperiment2(sysUID, dataGenPars);
tgenDataUID = toc(t1);

% store runtime information                 
runtimeInfo.tgenDataUID = tgenDataUID;

%% classifier training and averaging

% set configurations for exp2
experimentPars = configExp2();

% set number of train examples (per class) where to evaluate the gen. error
experimentPars.numExUsed = 10;   

% train classifier for the UID model at differing levels of obs. noise
resultsUID = trainClassifierExp2(dataUID, experimentPars);

%% postprocessing and plotting 
close all

% use current experimental data or load previous  results
loadResults = true;

if loadResults & analysis_mode
    load('Results/pExperiment2_batch_reactor_202411120208.mat')
    dataGenPars = resultsUID.data.dataGenPars;
end

% set plot styles
options.plotStyle.linestyle_UID = '--';
options.plotStyle.linestyle_UID_SIM = '-';

options.plotStyle.fullscreen = 0;
options.plotStyle.figuresize = [6 6 9 8];

options.plotStyle.fontname = 'Sans Serif';
options.plotStyle.axes_font_size = 8;
options.plotStyle.legend_font_size = 8;

options.plotStyle.linestyle_width = 1;

options.xLimits = [0 dataGenPars.sigmaObsVec(end)];
options.yLimits_errors = [0 0.5];

% create figure with results
if analysis_mode
    fig = plotOutcomesExperiment2(resultsUID, options);

    % set options for printing the PDF
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', options.plotStyle.figuresize(3:4));
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 options.plotStyle.figuresize(3:4)]);
    set(gcf, 'renderer', 'painters');

    print(gcf, '-dpdf', 'Figures/Exp2_BR.pdf');
end

%% save results for later use
filename = ['Results/Experiment2_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat'];
fprintf(['File name: Experiment2_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat\n'])
save(filename, 'resultsUID', 'options', 'runtimeInfo')
