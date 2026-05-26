function experimentPars = configExp3()

    % set numer of averaging runs
    experimentPars.numAvgRuns = 30;
    
    % configure hyper parameter tuning
    experimentPars = configHyperParameterTuning(experimentPars);

end