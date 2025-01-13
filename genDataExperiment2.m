function data = genDataExperiment2(sys, dataGenPars)
    
    % DESCRIPTION: Generates data for experiment 2. Generates a number of 
    % training and test data for the binary classification task specified
    % in dataGenPars. Creates data with varying levels of observational
    % noise.

    % INPUT:
    % dataGenPars:  struct containing data generating parameters
    
    % OUTPUT:           
    % data:         struct containing training and test data, and data
    %               generating parameters

    % unpack parameters for experimental setup
    numExamples = dataGenPars.numExamples;
    parClass = dataGenPars.parClass;
    t = dataGenPars.obsMode.t;
    sigmaObsVec = dataGenPars.sigmaObsVec;

    % init. struct. to hold generated data for different levels of noise
    noiseLevel = struct;

    % loop over the different levels of observational noise
    for i = 1:length(sigmaObsVec)

        % create timeseries data with given level of noise
        tsDataTrain = sys.genBinLabelTSGrid(numExamples.train, parClass, t, sigmaObsVec(i));
        tsDataTest = sys.genBinLabelTSGrid(numExamples.test, parClass, t, sigmaObsVec(i));
        
        % transform to MLE data 
        mleDataTrain = sys.tsData2mleData(tsDataTrain);
        mleDataTest = sys.tsData2mleData(tsDataTest);
    
        % store in struct
        noiseLevel(i).mleDataTrain = mleDataTrain;
        noiseLevel(i).mleDataTest = mleDataTest;
  
    end

    % store generate data in struct
    data.noiseLevel = noiseLevel;
    data.dataGenPars = dataGenPars;

end