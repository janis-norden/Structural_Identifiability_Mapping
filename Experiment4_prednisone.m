% Experiment 4: application to prednisone-prednisolone conversion

%% clear workspace, load data and define dynamical system
clear; clc; close all                                % clear workspace
rng(1)                                               % set random number generator seed for reproducibility
load('Data\prednisone.mat')                          % load data
sysUID = dynamical_system('prednisone', 'UID');      % define dynamical system

%% discard data to increase difficulty
P(2:2:12, :) = nan;

%% Plot observed data
close all

% define class colours
colours = {'red', 'blue', 'magenta'};

% create plot
figure
hold on
for n = [2, 3, 4, 5, 6, 7, 8, 9, 10]
    idx_missing = isnan(P(:, n)) | P(:, n) == 0;
    plot(ts(~idx_missing), P(~idx_missing, n), Color = colours{labels(n) + 1}, Marker='*', LineStyle='--');
end

idx_missing = isnan(P(:, 11)) | P(:, 11) == 0;
handle_slow = plot(ts(~idx_missing), P((~idx_missing), 11), Color = colours{labels(11) + 1}, Marker='*', LineStyle='--');
idx_missing = isnan(P(:, 12)) | P(:, 12) == 0;
handle_medium = plot(ts(~idx_missing), P((~idx_missing), 12), Color = colours{labels(12) + 1}, Marker='*', LineStyle='--');
idx_missing = isnan(P(:, 1)) | P(:, 1) == 0;
handle_fast = plot(ts(~idx_missing), P((~idx_missing), 1), Color = colours{labels(1) + 1}, Marker='*', LineStyle='--');
legend([handle_slow, handle_medium, handle_fast], 'Slow absorbers', 'Medium absorbers', 'Fast absorbers', Location='best')

xlim([0, 240])
xlabel('t (min)')
ylabel('y(t)')
title('Prednisone data')


%% extract number of observations and number of examples
[numObs, numExamples]  = size(P);

% loop over examples
observations = struct('truePar', {}, 'timeseries', {}, 'label', {});
for n = 1:numExamples
    
    % add timeseries info to struct
    observations(n).truePar = 0;
    observations(n).label = labels(n);
    
    % find where time series is nan or 0
    idx_missing = isnan(P(:, n)) | P(:, n) == 0;
    observations(n).timeseries = [ts(~idx_missing); P(~idx_missing, n)'];

end

% add info to tsData struct
tsData.observations = observations;
tsData.sigmaObs = 8;


%% Find Maximum Likelihood Estimates
mleData = findMLE(sysUID, tsData);

%% create feature matrices for theta and Phi features
X = [mleData.observations.MLE_theta]';      % extract MLE data
X_SIM = [mleData.observations.MLE_Phi]';    % extract SIM data
y = [mleData.observations.label]';          % extract labels

%% train classifier in theta-space

% set parameters for hyperparameter tuning
experimentPars = struct;
experimentPars = configHyperParameterTuning(experimentPars);
hyper_params = hyperparameters('fitcecoc', X, y, 'SVM');
hyper_params(1).Optimize = false;       
hyper_params(2).Range = experimentPars.HPTuning.boxConstraintRange;           
hyper_params(2).Transform = experimentPars.HPTuning.boxConstraintTransform;
hyper_params(3).Range = experimentPars.HPTuning.kernelScaleRange;            
hyper_params(3).Transform = experimentPars.HPTuning.kernelScaleTransform;
hyper_params(6).Optimize = experimentPars.HPTuning.optimizeStandardization;

tempSVM = templateSVM('Type', 'classification', 'KernelFunction', 'gaussian', 'Standardize', true);

% train the model with hyperparameter optimization
SVMModel = fitcecoc(X, y, 'Learners', tempSVM, 'HyperparameterOptimizationOptions', struct('UseParallel', true, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', 20, 'Kfold', 12), OptimizeHyperparameters = hyper_params);

% predict clas
yPredicted = SVMModel.predict(X);

% cross-validate
CVSVM = crossval(SVMModel, 'KFold', 12);
genError = kfoldLoss(CVSVM)
yPredCV = kfoldPredict(CVSVM);

%% train classifier in Phi-space

% set parameters for hyperparameter tuning
hyper_params = hyperparameters('fitcecoc', X_SIM, y, 'SVM');
hyper_params(1).Optimize = false;
hyper_params(2).Range = experimentPars.HPTuning.boxConstraintRange;           
hyper_params(2).Transform = experimentPars.HPTuning.boxConstraintTransform;
hyper_params(3).Range = experimentPars.HPTuning.kernelScaleRange;            
hyper_params(3).Transform = experimentPars.HPTuning.kernelScaleTransform;
hyper_params(6).Optimize = experimentPars.HPTuning.optimizeStandardization;

tempSVM = templateSVM('Type', 'classification', 'KernelFunction', 'gaussian', 'Standardize', true);

% train the model with hyperparameter optimization
SVMModelSIM = fitcecoc(X_SIM, y, 'Learners', tempSVM, 'HyperparameterOptimizationOptions', struct('UseParallel', true, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', 20, 'Kfold', 12), OptimizeHyperparameters = hyper_params);

% predict clas
yPredictedSIM = SVMModelSIM.predict(X_SIM);

% cross-validate
CVSVMSIM = crossval(SVMModelSIM, 'KFold', 12);
genError = kfoldLoss(CVSVMSIM)
yPredCVSIM = kfoldPredict(CVSVMSIM);

%% create plot of data, with confusion matrices for MLE and SIM classifiers

% define figure size
figuresize = [6 6 18 5];

% set plot styles
fontname = 'Sans Serif';
axes_font_size = 8;
legend_font_size = 8;

% define class colours
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
green = [0.4660 0.6740 0.1880];

colour_slow = green;
colour_med = blue;
colour_fast = orange;

linestyle_slow = '-';
linestyle_med = '--';
linestyle_fast = ':';

marker_slow = '*';
marker_med = 'o';
marker_fast = '^';


% Make plot
fig = figure(1);
clf(fig);
set(fig,'units', 'centimeters', 'color', 'white', 'position', figuresize, 'PaperPositionMode', 'auto');
tiledlayout(1, 3, 'Padding', 'none', 'TileSpacing', 'loose'); 

% --- Panel a ---
nexttile;
hold on

% plot data
for n = [2, 3, 4, 5, 6, 7, 8, 9, 10]
    idx_missing = isnan(P(:, n)) | P(:, n) == 0;
    
    if labels(n) == 0
        plot(ts(~idx_missing), P(~idx_missing, n), Color = colour_slow, Marker=marker_slow, LineStyle=linestyle_slow);
    elseif labels(n) == 1
        plot(ts(~idx_missing), P(~idx_missing, n), Color = colour_med, Marker=marker_med, LineStyle=linestyle_med);
    else
        plot(ts(~idx_missing), P(~idx_missing, n), Color = colour_fast, Marker=marker_fast, LineStyle=linestyle_fast);
    end
end

% create plot with labels, one for each class 
idx_missing = isnan(P(:, 11)) | P(:, 11) == 0;
handle_slow = plot(ts(~idx_missing), P((~idx_missing), 11), Color = colour_slow, Marker=marker_slow, LineStyle=linestyle_slow);
idx_missing = isnan(P(:, 12)) | P(:, 12) == 0;
handle_medium = plot(ts(~idx_missing), P((~idx_missing), 12),  Color = colour_med, Marker=marker_med, LineStyle=linestyle_med);
idx_missing = isnan(P(:, 1)) | P(:, 1) == 0;
handle_fast = plot(ts(~idx_missing), P((~idx_missing), 1), Color = colour_fast, Marker=marker_fast, LineStyle=linestyle_fast);

% add legend
lgd = legend([handle_slow, handle_medium, handle_fast], 'Slow absorbers', 'Medium absorbers', 'Fast absorbers', 'Interpreter', 'latex', Location='best');
fontsize(lgd, legend_font_size, 'points')

% annotations
xlim([0, 240])
ylim([0, 200])
xlabel('minutes', 'Interpreter','latex')
ylabel('concentration', 'Interpreter','latex')
title('a) Prednisone data', 'Interpreter','latex')
set(gca, 'fontsize', axes_font_size)

% --- Panel b ---
nexttile;

% create confusion matrix chart
cm = confusionchart(labelToStr(y), labelToStr(yPredCV));

% annotations
cm.Title = 'b) Confusion matrix PO model';
cm.FontName = fontname;
cm.Interpreter = 'latex';
set(gca, 'fontsize', axes_font_size)

% --- Panel c ---
nexttile;

% create confusion matrix chart
cmSIM = confusionchart(labelToStr(y), labelToStr(yPredCVSIM));

% annotations
cmSIM.Title = 'c) Conf. matrix PO model + SIM';
cmSIM.FontName = fontname;
cmSIM.Interpreter = "latex";
set(gca, 'fontsize', axes_font_size)

% set options for printing the PDF
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [18.13 5]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 18.13 5]);
set(gcf, 'renderer', 'painters');

% create figure with results
print(gcf, '-dpdf', 'Figures/Exp4_prednisone.pdf');


%% FUNCTIONS

function yString = labelToStr(y)
    
    % converts from numerical labels 0, 1, 2 to strings slow, medium, fast
    
    yString = cell(length(y), 1);
    for i = 1:length(y)
        if y(i) == 0
            yString{i} = 'slow';
        elseif y(i) == 1
            yString{i} = 'med.';
        else
            yString{i} = 'fast';
        end
    end
end

function mleData = findMLE(dynamical_system, tsData)

    % DESCRIPTION:  Find Maximum Likelihood Estimate (MLE) for each timeseries observation in tsData and appends to tsData.

    % INPUT:
    % tsData:   struct containing the timeseries data for the binary classification task

    % OUTPUT:               
    % mleData:  struct copy of tsData with added Maximum Likelihood Estimates (MLE)

    % Unpack sigma and number of observations from input data
    sigmaObs = tsData.sigmaObs;
    numObs = size(tsData.observations, 2);

    % set threshold for Chi-Squ. CDF
    alpha = 0.999;
    xThreshold = chi2inv(alpha, 1);
    
    % initialize structure to hold observations
    observations = struct('truePar', {}, 'timeseries', {}, 'MLE_theta', {}, 'MLE_Phi', {}, 'label', {}, 'optExitFlag', {});

    % set bounds and options for simulated annealing
    lb = dynamical_system.ROI(:, 1);
    ub = dynamical_system.ROI(:, 2);
    options = optimoptions(@simulannealbnd, 'Display', 'off', 'TimeLimit', 60);
    
    % unpack to avoid having to communicate to all workers
    LogLikelihoodFunHandle = @(timeseries, pars, sigmaObs) dynamical_system.LogLikelihoodFun(timeseries, pars, sigmaObs);
    tsDataObs = tsData.observations;
    calcMSEHandle = @(param, timeseries) dynamical_system.calcMSE(param, timeseries);
    SI_relationHandle = @(param) dynamical_system.SI_relation(param);
    
    % Loop over number of observations
    for obs = 1:numObs
        
        % set negative log-likelihood function and draw x0 from ROI
        fun = @(pars) -(LogLikelihoodFunHandle(tsDataObs(obs).timeseries, pars, sigmaObs));
        
        % loop to exclude outliers from MLE using MSE test
        selected = false;
        while selected == false

            % find suitable initial point (100 trials)
            x0_select = unifrnd(lb, ub);
            for cnt = 1:100
                x0 = unifrnd(lb, ub);
                llogCurrent = fun(x0_select);
                llogNew = fun(x0);
                if ~isinf(llogNew) && llogNew < llogCurrent
                    x0_select = x0;
                end
            end
            
            % solve constrained minimization problem
            [MLECand, ~, exitflag, ~] = simulannealbnd(fun, x0_select, lb, ub, options);

            % calculate MSE between MLE solution and input timeseries
            MSE = calcMSEHandle(MLECand, tsDataObs(obs).timeseries);
            
            % check if observation is within alpha% range, otherwise discard
            if MSE / (sigmaObs^2) <= xThreshold
                selected = true;
            end
        end

        % store MLE and label in observations struct
        observations(obs).truePar = tsDataObs(obs).truePar;
        observations(obs).timeseries = tsDataObs(obs).timeseries;
        observations(obs).MLE_theta = MLECand;
        observations(obs).MLE_Phi = SI_relationHandle(MLECand')';
        observations(obs).label = tsDataObs(obs).label;
        observations(obs).optExitFlag = exitflag;
        
    end
    mleData.observations = observations;
    mleData.sigmaObs = sigmaObs;

end