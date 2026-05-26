function data = genDataExperiment2(sys, dataGenPars)

    % unpack parameters for experimental setup
    numExamples = dataGenPars.numExamples;
    parClass = dataGenPars.parClass;
    t = dataGenPars.obsMode.t;
    SNRVec = dataGenPars.SNRVec;

    % loop over test set and create trajectories to find P_signal
    tsDataSNR = sys.genBinLabelTSGrid(dataGenPars.numExamples.test, parClass, t, 0);
    signalPowers = zeros(dataGenPars.numExamples.test, 1);
    for i = 1: dataGenPars.numExamples.test
        
        % extract timeseries
        ts = tsDataSNR.observations(i).timeseries(2, :);

        % estimate signal power
        signalPowers(i) = (1 / (t(end) - t(1))) * trapz(t, ts .^2);

    end
    
    % find average signal power
    avgSignalPower = mean(signalPowers);
    
    % find sigma values associated with the wanted SNRs
    sigmaObsVec = sqrt(avgSignalPower ./ SNRVec);
    dataGenPars.sigmaObsVec = sigmaObsVec;

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