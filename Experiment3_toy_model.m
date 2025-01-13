% Experiment 3: grid types (UID vs. UID + SIM)

% Model: toy model

%% select model
clear; clc; close all;                               % clear workspace
load('analysis_mode.mat')                            % check if analysis mode is on
rng(1)                                               % set random number generator seed for reproducibility
sysUID = dynamical_system('toy_model', 'UID');       % select example model and identifiability status

disp('Running experiment 3 - toy_model')             % display running message
%% define classification problem and set data generation parameters

% ---------------- CLASSIFICATION PROBLEM -------------------------------->
% Set parameter values associated with class 0 and class 1
dataGenPars.parClass.C0.mu = [1, 1];
dataGenPars.parClass.C1.mu = 0.9 * [1, 1];

% set covariance matrix for intra-class variation
dataGenPars.parClass.C0.Sigma = diag([10^-4, 10^-4]);
dataGenPars.parClass.C1.Sigma = diag([10^-4, 10^-4]);
% ------------------------------------------------------------------------<

% ---------------- DATA GENERATION PARAMETERS ---------------------------->

% Select number of training and test examples to produce
dataGenPars.numExamples.train = 100;
dataGenPars.numExamples.test = 200;

% Set times at which to evaluate analytic solution
dataGenPars.obsMode.t = 0:0.1:1;                          % full grid
dataGenPars.obsMode.sparseGridFact = 0.4;                 % sparsegrid/irr.

% set std. of observational noise (Gaussian) added to timeseries
dataGenPars.sigmaObs = 0.01;                    % fixed for this experiment
% ------------------------------------------------------------------------<

%% generate timeseries and maximum likelihood estimates for ID and UID model

% generate data for UID model
t1 = tic;
dataUID = genDataExperiment3(sysUID, dataGenPars);
tgenDataUID = toc(t1);

% store runtime information
runtimeInfo.tgenDataUID = tgenDataUID;

%% classifier training and averaging

% set configurations for exp3
experimentPars = configExp3();

% set increments of training examples at which to train classifier
experimentPars.numTrExVec = 10:10:dataGenPars.numExamples.train;   

% train classifier for UID model
resultsUID = trainClassifierExp3(dataUID, experimentPars);

%% postprocessing and plotting 
close all

% use current experimental data or load previous  results
loadResults = true;

if loadResults & analysis_mode
    load('Results/pExperiment3_toy_model_202411121000.mat')
    dataGenPars.numExamples.train = resultsUID.data.dataGenPars.numExamples.train;
    dataUID = resultsUID.data;
end

% set plot styles
options.plotStyle.linestyle_UID = '--';
options.plotStyle.linestyle_UID_SIM = '-';

options.plotStyle.fullscreen = 0;
options.plotStyle.figuresize = [6 6 18 5];

options.plotStyle.fontname = 'Sans Serif';
options.plotStyle.axes_font_size = 8;
options.plotStyle.legend_font_size = 8;

options.plotStyle.linestyle_width = 1;

options.xLimits = [0 dataGenPars.numExamples.train];
options.yLimits_errors = [0 0.2];

% set options for printing the PDF
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [18.13 5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 18.13 5]);
set(gcf, 'renderer', 'painters');

% create figure with results
if analysis_mode
    fig = plotOutcomesExperiment3GenErrOnly(resultsUID, options);
    print(gcf, '-dpdf', 'Figures/Exp3_toy_model.pdf');
end

%% save results for later use
filename = ['Results/Experiment3_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat'];
fprintf(['File name: Experiment3_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat\n'])
save(filename, 'resultsUID', 'options', 'runtimeInfo')
