function results = trainSVMExp1(data, experimentPars)

    % DESCRIPTION: Train SVM classifiers on original and preprocessed data
    % for different amounts of data and different levels of noise.

    % INPUT:
    % data:             struct containing binary classification task
    % experimentPars:   struct containing experiment configurations
    
    % OUTPUT:           
    % results:          struct containing the results of the experiment
    
    % Extract number of noise levels from data set
    numTrExVec = experimentPars.numTrExVec;
    numAvgRuns = experimentPars.numAvgRuns;

    NumGridDivisions = experimentPars.NumGridDivisions;
    Kfold = experimentPars.Kfold;
    
    % Initialize outcomes structures
    train_error = zeros(length(numTrExVec), numAvgRuns);
    train_error_SIM = zeros(length(numTrExVec), numAvgRuns);
    val_error = zeros(length(numTrExVec), numAvgRuns);
    val_error_SIM = zeros(length(numTrExVec), numAvgRuns);
    gen_error = zeros(length(numTrExVec), numAvgRuns);
    gen_error_SIM = zeros(length(numTrExVec), numAvgRuns);
    numSuppVec = zeros(length(numTrExVec), numAvgRuns);
    numSuppVec_SIM = zeros(length(numTrExVec), numAvgRuns);

    kernelScales = zeros(length(numTrExVec), numAvgRuns);
    kernelScales_SIM = zeros(length(numTrExVec), numAvgRuns);
    boxConstraints = zeros(length(numTrExVec), numAvgRuns);
    boxConstraints_SIM = zeros(length(numTrExVec), numAvgRuns);
    
    % Extract test data from data set
    X_test = [data.mleDataTest.observations.MLE_theta]';
    X_test_SIM = [data.mleDataTest.observations.MLE_Phi]';
    y_test = [data.mleDataTest.observations.label]';
    
    % Extract training data
    X_train = [data.mleDataTrain.observations.MLE_theta]';
    X_train_SIM = [data.mleDataTrain.observations.MLE_Phi]';
    y_train = [data.mleDataTrain.observations.label]';
    
    % find all indices associated with class 0 and 1
    idx_C0 = find(y_train == 0);
    idx_C1 = find(y_train == 1);
    
    % parameters for hyperparameter tuning
    hyper_params = hyperparameters('fitcsvm', X_train, y_train);
    
    hyper_params(1).Range = experimentPars.HPTuning.boxConstraintRange;           
    hyper_params(1).Transform = experimentPars.HPTuning.boxConstraintTransform;

    hyper_params(2).Range = experimentPars.HPTuning.kernelScaleRange;            
    hyper_params(2).Transform = experimentPars.HPTuning.kernelScaleTransform;
    
    hyper_params(5).Optimize = experimentPars.HPTuning.optimizeStandardization;

    % Loop over different amounts of training data
    for j = 1:length(numTrExVec)
    
        % Averaging runs
        for k = 1:numAvgRuns
        
            % draw numTrExVec(j) training examples from both classes
            idx_select_C0 = randsample(idx_C0, numTrExVec(j));
            idx_select_C1 = randsample(idx_C1, numTrExVec(j));
            idx_select = [idx_select_C0; idx_select_C1];

            X = X_train(idx_select, :);
            X_SIM = X_train_SIM(idx_select, :);
            y = y_train(idx_select);

            % -------------Train SVM-------------
            SVMModel = fitcsvm(X, y, 'Standardize', true, 'KernelFunction', 'gaussian', 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', NumGridDivisions, 'Kfold', Kfold), OptimizeHyperparameters = hyper_params);
            SVMModel_SIM = fitcsvm(X_SIM, y, 'Standardize', true, 'KernelFunction', 'gaussian', 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', NumGridDivisions, 'Kfold', Kfold), OptimizeHyperparameters = hyper_params);
            
            % Save SVM kernel scales & box constraints
            kernelScales(j, k) = SVMModel.ModelParameters.KernelScale;  
            kernelScales_SIM(j, k) = SVMModel_SIM.ModelParameters.KernelScale;  
            boxConstraints(j, k) = SVMModel.ModelParameters.BoxConstraint;
            boxConstraints_SIM(j, k) = SVMModel_SIM.ModelParameters.BoxConstraint;
            
            % Do SVM predictions on train set and store training error
            SVMLabel_train = predict(SVMModel, X);
            SVMLabel_SIM_train = predict(SVMModel_SIM, X_SIM);
            train_error(j, k) = sum(abs(SVMLabel_train - y)) / length(y);
            train_error_SIM(j, k) = sum(abs(SVMLabel_SIM_train - y)) / length(y);

            % Store validation error
            val_error(j, k) = min(SVMModel.HyperparameterOptimizationResults.Objective);
            val_error_SIM(j, k) = min(SVMModel_SIM.HyperparameterOptimizationResults.Objective);

            % Do SVM predictions on test set and store generalization error
            SVMLabel = predict(SVMModel, X_test);
            SVMLabel_SIM = predict(SVMModel_SIM, X_test_SIM);
            gen_error(j, k) = sum(abs(SVMLabel - y_test)) / length(y_test);
            gen_error_SIM(j, k) = sum(abs(SVMLabel_SIM - y_test)) / length(y_test);
            
            % SVM calculate number of support vectors
            numSuppVec(j, k) = length(SVMModel.SupportVectorLabels);
            numSuppVec_SIM(j, k) = length(SVMModel_SIM.SupportVectorLabels);

        end

    end

    % collect outcomes in structs
    SVM_outcomes.train_error = train_error;
    SVM_outcomes_SIM.train_error = train_error_SIM;

    SVM_outcomes.val_error = val_error;
    SVM_outcomes_SIM.val_error = val_error_SIM;

    SVM_outcomes.gen_error = gen_error;
    SVM_outcomes_SIM.gen_error = gen_error_SIM;

    SVM_outcomes.numSuppVec = numSuppVec;
    SVM_outcomes_SIM.numSuppVec = numSuppVec_SIM;

    SVM_outcomes.kernelScales = kernelScales;
    SVM_outcomes_SIM.kernelScales = kernelScales_SIM;
    
    SVM_outcomes.boxConstraints = boxConstraints;
    SVM_outcomes_SIM.boxConstraints = boxConstraints_SIM;

    % save experiment input and settings
    results.data = data;
    results.experimentPars = experimentPars;
    
    outcomes.SVM = SVM_outcomes;
    outcomes.SVM_SIM = SVM_outcomes_SIM;

    results.outcomes = outcomes;

end