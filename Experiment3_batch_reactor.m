% Experiment 3: grid types (UID vs. UID + SIM)

% Model: batch_reactor

%% select model
clear; clc; close all;                               % clear workspace
load('analysis_mode.mat')                            % check if analysis mode is on
rng(1)                                               % set random number generator seed for reproducibility
sysUID = dynamical_system('batch_reactor', 'UID');   % select example model and identifiability status

disp('Running experiment 3 - batch_reactor')         % display running message
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
dataGenPars.numExamples.train = 200;
dataGenPars.numExamples.test = 400;

% Set times at which to evaluate analytic solution
dataGenPars.obsMode.t = 0:1:12;                           % full grid
dataGenPars.obsMode.sparseGridFact = [0.25, 0.4];         % sparse grid/irr.

% set std. of observational noise (Gaussian) added to timeseries
dataGenPars.sigmaObs = 1;                       % fixed for this experiment
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
experimentPars.numTrExVec = [10, 25:25:dataGenPars.numExamples.train];   

% train SVM classifier for UID model
t2 = tic;
resultsSVM = trainSVMExp3(dataUID, experimentPars);
tSVM = toc(t2);
runtimeInfo.tSVM = tSVM;

% train MLP classifier on time series directly using GP imputation
t3 = tic;
resultsMLPGP = trainMLPExp3(dataUID, experimentPars, 'gaussian_process');
tMLPGP = toc(t3);
runtimeInfo.tMLPGP = tMLPGP;
resultsMLP.GP = resultsMLPGP;

% train MLP classifier on time series directly using LR imputation
t4 = tic;
resultsMLPLR = trainMLPExp3(dataUID, experimentPars, 'linear_regression');
tMLPLR = toc(t4);
runtimeInfo.tMLPLR = tMLPLR;
resultsMLP.LR = resultsMLPLR;

%% postprocessing and plotting 
close all

% use current experimental data or load previous results
loadResults = true;

if loadResults & analysis_mode
    load('Results/prExperiment3_batch_reactor_202507291952')
    dataGenPars.numExamples.train = resultsSVM.data.dataGenPars.numExamples.train;
end

% set plot styles
options.plotStyle.linestyle_UID = '--';
options.plotStyle.linestyle_UID_SIM = '-';
options.plotStyle.linestyle_MLP = ':';

options.plotStyle.fullscreen = 0;
options.plotStyle.figuresize = [6 6 18.13 5];

options.plotStyle.fontname = 'Sans Serif';
options.plotStyle.axes_font_size = 8;
options.plotStyle.legend_font_size = 8;

options.plotStyle.linestyle_width = 1;

options.xLimits = [0 dataGenPars.numExamples.train];
options.yLimits_errors = [0 0.5];

% set options for printing the PDF
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [18.13 5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 18.13 5]);
set(gcf, 'renderer', 'painters');

% create figure with results
if analysis_mode
    % fig = plotOutcomesExperiment3GenErrOnly(resultsSVM, options);
    fig = plotOutcomesExperiment3(resultsSVM, options);
    print(gcf, '-dpdf', 'Figures/Exp3_BR.pdf');
end

%% save results for later use
filename = ['Results/Experiment3_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat'];
fprintf(['File name: Experiment3_', sysUID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat\n'])
save(filename, 'resultsSVM', 'resultsMLP', 'options', 'runtimeInfo')
