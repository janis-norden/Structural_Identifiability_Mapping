function experimentPars = configExp3()
    
    % DESCRIPTION: Set configuration for experiment 3. Set number of
    % averaging runs to perform and load configurations for hyperparameter
    % tuning.

    % set numer of averaging runs
    experimentPars.numAvgRuns = 20;
    
    % configure hyper parameter tuning
    experimentPars = configHyperParameterTuning(experimentPars);

end