% Experiment 3: grid types (UID vs. UID + SIM)

% Model: CCM2

%% select model
clear; clc; close all;                               % clear workspace
load('analysis_mode.mat')                            % check if analysis mode is on
rng(1)                                               % set random number generator seed for reproducibility
sysUID = dynamical_system('CCM2', 'UID');            % select example model and identifiability status


disp('Running experiment 3 - CCM2')                  % display running message
%% define classification problem and set data generation parameters

% ---------------- CLASSIFICATION PROBLEM -------------------------------->
% Set parameter values associated with class 0 and class 1
kPex_C4 = 0.015;
kLP_C4 = 0.01;
a_C4 = -0.13511;
b_C4 = 0.01675;
dataGenPars.parClass.C0.mu = [kPex_C4, a_C4 * kPex_C4 + b_C4, 7.40155 * kLP_C4, kLP_C4];
dataGenPars.parClass.C1.mu = [kPex_C4, a_C4 * kPex_C4 + b_C4, 0.8 * 7.40155 * kLP_C4, 0.8 * kLP_C4];

% set covariance matrix for intra-class variation
dataGenPars.parClass.C0.Sigma = 10^-7 * eye(4);
dataGenPars.parClass.C1.Sigma = 10^-7 * eye(4);
% ------------------------------------------------------------------------<

% ---------------- DATA GENERATION PARAMETERS ---------------------------->

% Select number of training and test examples to produce
dataGenPars.numExamples.train = 100;
dataGenPars.numExamples.test = 200;

% Set times at which to evaluate analytic solution
dataGenPars.obsMode.t = 0:10:240;                         % full grid
dataGenPars.obsMode.sparseGridFact = 0.4;                 % sparsegrid/irr.

% set std. of observational noise (Gaussian) added to timeseries
dataGenPars.sigmaObs = 10;                      % fixed for this experiment
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
    load('Results/pExperiment3_CCM2_202411120525.mat')
    dataGenPars.numExamples.train = resultsUID.data.dataGenPars.numExamples.train;
end

% set plot styles
options.plotStyle.linestyle_UID = '--';
options.plotStyle.linestyle_UID_SIM = '-';

options.plotStyle.fullscreen = 0;
options.plotStyle.figuresize = [6 6 18.13 5];

options.plotStyle.fontname = 'Sans Serif';
options.plotStyle.axes_font_size = 8;
options.plotStyle.legend_font_size = 8;

options.plotStyle.linestyle_width = 1;

options.xLimits = [0 dataGenPars.numExamples.train];
options.yLimits_errors = [0 0.4];

% set options for printing the PDF
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [18.13 5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 18.13 5]);
set(gcf, 'renderer', 'painters');

% create figure with results
if analysis_mode
    fig = plotOutcomesExperiment3GenErrOnly(resultsUID, options);
    print(gcf, '-dpdf', 'Figures/Exp3_CCM2.pdf');
end

%% save results for later use
filename = ['Results/Experiment3_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat'];
fprintf(['File name: Experiment3_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat\n'])
save(filename, 'resultsUID', 'options', 'runtimeInfo')
