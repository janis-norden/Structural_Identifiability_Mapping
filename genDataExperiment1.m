function data = genDataExperiment1(sys, dataGenPars)

    % DESCRIPTION: Generates data for experiment 1. Generates a number of 
    % training and test data for the binary classification task specified
    % in dataGenPars.

    % INPUT:
    % dataGenPars:  struct containing data generating parameters
    
    % OUTPUT:           
    % data:         struct containing training and test data, and data
    %               generating parameters
    

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