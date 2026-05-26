function experimentPars = configExp2()

    % set numer of averaging runs
    experimentPars.numAvgRuns = 50;
    
    % configure hyper parameter tuning
    experimentPars = configHyperParameterTuning(experimentPars);

end