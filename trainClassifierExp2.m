function results = trainClassifierExp2(data, experimentPars)
    % DESCRIPTION: Train SVM classifiers on original and preprocessed data 
    % for different amounts of data and different levels of noise.

    % INPUT:
    % data:             struct containing binary classification task
    % experimentPars:   struct containing experiment configurations
    
    % OUTPUT:           
    % results:          struct containing the results of the experiment

    % Extract number of noise levels from data set
    numAvgRuns = experimentPars.numAvgRuns;
    numExUsed = experimentPars.numExUsed;
    sigmaObsVec = data.dataGenPars.sigmaObsVec;

    NumGridDivisions = experimentPars.NumGridDivisions;
    Kfold = experimentPars.Kfold;
    
    % Initialize outcomes structures
    train_error = zeros(length(sigmaObsVec), numAvgRuns);
    train_error_SIM = zeros(length(sigmaObsVec), numAvgRuns);
    val_error = zeros(length(sigmaObsVec), numAvgRuns);
    val_error_SIM = zeros(length(sigmaObsVec), numAvgRuns);
    gen_error = zeros(length(sigmaObsVec), numAvgRuns);
    gen_error_SIM = zeros(length(sigmaObsVec), numAvgRuns);
    numSuppVec = zeros(length(sigmaObsVec), numAvgRuns);
    numSuppVec_SIM = zeros(length(sigmaObsVec), numAvgRuns);

    % loop over different amounts of observational noise
    parfor j = 1:length(sigmaObsVec)

        % Extract test data from data set
        X_test = [data.noiseLevel(j).mleDataTest.observations.MLE_theta]';
        X_preprc_test = [data.noiseLevel(j).mleDataTest.observations.MLE_Phi]';
        y_test = [data.noiseLevel(j).mleDataTest.observations.label]';

        % Extract training data
        X_train = [data.noiseLevel(j).mleDataTrain.observations.MLE_theta]';
        X_train_Phi = [data.noiseLevel(j).mleDataTrain.observations.MLE_Phi]';
        y_train = [data.noiseLevel(j).mleDataTrain.observations.label]';
        
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

        % Averaging runs
        for k = 1:numAvgRuns
            
            % draw numTrExVec(j) training examples from both classes
            idx_select_C0 = randsample(idx_C0, numExUsed);
            idx_select_C1 = randsample(idx_C1, numExUsed);
            idx_select = [idx_select_C0; idx_select_C1];

            X = X_train(idx_select, :);
            X_SIM = X_train_Phi(idx_select, :);
            y = y_train(idx_select);

            % -------------Train SVM-------------
            SVMModel = fitcsvm(X, y, 'Standardize', true, 'KernelFunction', 'gaussian', 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', NumGridDivisions, 'Kfold', Kfold), OptimizeHyperparameters = hyper_params);
            SVMModel_SIM = fitcsvm(X_SIM, y, 'Standardize', true, 'KernelFunction', 'gaussian', 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', NumGridDivisions, 'Kfold', Kfold), OptimizeHyperparameters = hyper_params);
    
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
            SVMLabel_SIM = predict(SVMModel_SIM, X_preprc_test);
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

    % save experiment input and settings
    results.data = data;
    results.experimentPars = experimentPars;
    
    outcomes.SVM = SVM_outcomes;
    outcomes.SVM_SIM = SVM_outcomes_SIM;
    
    results.outcomes = outcomes;

end