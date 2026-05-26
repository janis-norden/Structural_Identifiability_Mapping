function data = genDataExperiment1(sys, dataGenPars)

    % unpack parameters for experimental setup
    numExamples = dataGenPars.numExamples;
    parClass = dataGenPars.parClass;
    t = dataGenPars.obsMode.t;
    sigmaObs = dataGenPars.sigmaObs;

    % create timeseries data 
    tsDataTrain = sys.genBinLabelTSGrid(numExamples.train, parClass, t, sigmaObs);
    tsDataTest = sys.genBinLabelTSGrid(numExamples.test, parClass, t, sigmaObs);
    
    % transform to MLE data 
    mleDataTrain = sys.tsData2mleData(tsDataTrain);
    mleDataTest = sys.tsData2mleData(tsDataTest);

    % store in struct
    data.mleDataTrain = mleDataTrain;
    data.mleDataTest = mleDataTest;
    data.dataGenPars = dataGenPars;

end