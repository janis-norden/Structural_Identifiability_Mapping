function experimentPars = configHyperParameterTuning(experimentPars)
    
    % DESCRIPTION: Set configuration hyperparameter tuning in SVM training.
    % Set number of grid divisions for grid search on each parameter.
    % Set number of folds for k-fold cross-validation.
    % Set range for box constraint grid search and whether the grid is
    % linear or log-scaled.
    % Set range for box kernel scale grid search and whether the grid is
    % linear or log-scaled.
    % Deactivate optimization of the standardization function -> always
    % standardize data

    % set hyper-parameter tuning options
    experimentPars.NumGridDivisions = 20;   %20
    experimentPars.Kfold = 10;

    experimentPars.HPTuning.boxConstraintRange = [10^-3, 10^3];
    experimentPars.HPTuning.boxConstraintTransform = 'log';

    experimentPars.HPTuning.kernelScaleRange = [0.01, 100];
    experimentPars.HPTuning.kernelScaleTransform = 'log';

    experimentPars.HPTuning.optimizeStandardization = false;

end