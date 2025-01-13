% Experiment 1: ID vs. UID vs. UID + SIM

% Model: CCM2 (Prednisone)

%% select model
clear; clc; close all;                               % clear workspace
load('analysis_mode.mat')                            % check if analysis mode is on
rng(1)                                               % set random number generator seed for reproducibility
sysID = dynamical_system('CCM2', 'ID');              % select example model and identifiability status
sysUID = dynamical_system('CCM2', 'UID');

disp('Running experiment 1 - CCM2')                  % display running message
%% define classification problem and set )

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
dataGenPars.obsMode.t = 0:10:240;

% set std. of observational noise (Gaussian) added to timeseries
dataGenPars.sigmaObs = 10;                       % fixed for this experiment
% ------------------------------------------------------------------------<
%% generate timeseries and maximum likelihood estimates for ID and UID model

% generate data for ID model
t1 = tic;
dataID = genDataExperiment1(sysID, dataGenPars);
tgenDataID = toc(t1);

% generate data for UID model
t2 = tic;
dataUID = genDataExperiment1(sysUID, dataGenPars);
tgenDataUID = toc(t2);

% store runtime information
runtimeInfo.tgenDataID = tgenDataID;
runtimeInfo.tgenDataUID = tgenDataUID;

%% classifier training and averaging

% set configurations for exp1
experimentPars = configExp1();

% set increments of training examples at which to train classifier
experimentPars.numTrExVec = 10:10:dataGenPars.numExamples.train;   

% train classifiers for both ID and UID model
results_ID_SVM = trainSVMExp1(dataID, experimentPars);
results_UID_SVM = trainSVMExp1(dataUID, experimentPars);

results_ID_LDA = trainLDAExp1(dataID, experimentPars);
results_UID_LDA = trainLDAExp1(dataUID, experimentPars);

%% postprocessing and plotting 
close all

% use current experimental data or load previous  results
loadResults = true;

if loadResults & analysis_mode
    load('Results/pExperiment1_CCM2_202411112007.mat')
    dataGenPars.numExamples.train = results_ID_LDA.data.dataGenPars.numExamples.train;
    dataID = results_ID_SVM.data;
    dataUID = results_UID_SVM.data;
end

% set plot styles
options.plotStyle.linestyle_ID = ':';
options.plotStyle.linestyle_UID = '--';
options.plotStyle.linestyle_UID_SIM = '-';

options.plotStyle.fullscreen = 0;
options.plotStyle.figuresize = [6 6 9 8];

options.plotStyle.fontname = 'Sans Serif';
options.plotStyle.axes_font_size = 8;
options.plotStyle.legend_font_size = 8;

options.plotStyle.linestyle_width = 1;

options.plotStyle.xScale = 'linear';
options.plotStyle.yScale = 'linear';

options.xLimits = [0 dataGenPars.numExamples.train];
options.yLimits_errors = [0 0.2];

% create figures with results
if analysis_mode
    fig1 = plotOutcomesExperiment1(results_ID_SVM, results_UID_SVM, options);
    
    % set options for printing the PDF
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', options.plotStyle.figuresize(3:4));
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 options.plotStyle.figuresize(3:4)]);
    set(gcf, 'renderer', 'painters');

    print(gcf, '-dpdf', 'Figures/Exp1_CCM2.pdf');
end

%% save results for later use
filename = ['Results/Experiment1_', sysID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat'];
fprintf(['File name: Experiment1_', sysID.name ,'_', datestr(now, 'yyyymmddHHMM'), '.mat\n'])
save(filename, 'results_ID_SVM', 'results_UID_SVM', 'results_ID_LDA', 'results_UID_LDA', 'options', 'runtimeInfo')
