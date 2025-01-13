function experimentPars = configExp2()
    
    % DESCRIPTION: Set configuration for experiment 2. Set number of
    % averaging runs to perform and load configurations for hyperparameter
    % tuning.

    % set numer of averaging runs
    experimentPars.numAvgRuns = 20;
    
    % configure hyper parameter tuning
    experimentPars = configHyperParameterTuning(experimentPars);

end