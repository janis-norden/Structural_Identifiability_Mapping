function experimentPars = configHyperParameterTuning(experimentPars)

    % set hyper-parameter tuning options
    experimentPars.NumGridDivisions = 20;   %20
    experimentPars.Kfold = 10;

    experimentPars.HPTuning.boxConstraintRange = [10^-3, 10^3];
    experimentPars.HPTuning.boxConstraintTransform = 'log';

    experimentPars.HPTuning.kernelScaleRange = [0.01, 100];
    experimentPars.HPTuning.kernelScaleTransform = 'log';

    experimentPars.HPTuning.optimizeStandardization = false;

end