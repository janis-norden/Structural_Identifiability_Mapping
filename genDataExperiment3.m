function data = genDataExperiment3(sys, dataGenPars)
    
    % DESCRIPTION: Generates data for experiment 3. Generates a number of 
    % training and test data for the binary classification task specified
    % in dataGenPars. Creates data with on three different time grids:
    % dense, sparse and irregular.

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
    sparseGridFact = dataGenPars.obsMode.sparseGridFact;
  
    % extract sparsity factor and create sparse grid
    deltat = 1 / sparseGridFact;
    tSparse = t(1:deltat:end);

    % create timeseries data on full grid
    tsDataTrainDense = sys.genBinLabelTSGrid(numExamples.train, parClass, t, sigmaObs);
    tsDataTestDense = sys.genBinLabelTSGrid(numExamples.test, parClass, t, sigmaObs);

    tsDataTrainSparse = sys.genBinLabelTSGrid(numExamples.train, parClass, tSparse, sigmaObs);
    tsDataTestSparse = sys.genBinLabelTSGrid(numExamples.test, parClass, tSparse, sigmaObs);
    
    tsDataTrainIrr = sys.genBinLabelTSIrrRand(numExamples.train, parClass, t, sigmaObs, sparseGridFact);
    tsDataTestIrr = sys.genBinLabelTSIrrRand(numExamples.test, parClass, t, sigmaObs, sparseGridFact);

    % transform to MLE data 
    mleDataTrainDense = sys.tsData2mleData(tsDataTrainDense);
    mleDataTestDense = sys.tsData2mleData(tsDataTestDense);

    mleDataTrainSparse = sys.tsData2mleData(tsDataTrainSparse);
    mleDataTestSparse = sys.tsData2mleData(tsDataTestSparse);

    mleDataTrainIrr = sys.tsData2mleData(tsDataTrainIrr);
    mleDataTestIrr = sys.tsData2mleData(tsDataTestIrr);

    % store in struct
    dense.mleDataTrain = mleDataTrainDense;
    dense.mleDataTest = mleDataTestDense;
    sparse.mleDataTrain = mleDataTrainSparse;
    sparse.mleDataTest = mleDataTestSparse;
    irr.mleDataTrain = mleDataTrainIrr;
    irr.mleDataTest = mleDataTestIrr;

    data.dense = dense;
    data.sparse = sparse;
    data.irr = irr;
    data.dataGenPars = dataGenPars;

end