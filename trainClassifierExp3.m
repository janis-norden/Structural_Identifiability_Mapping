function results = trainClassifierExp3(data, experimentPars)
    
    % DESCRIPTION: Train SVM classifiers on original and preprocessed data
    % for different amounts of data and different types of time grids.

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
    train_error = zeros(length(numTrExVec), numAvgRuns, 3);
    train_error_SIM = zeros(length(numTrExVec), numAvgRuns, 3);
    val_error = zeros(length(numTrExVec), numAvgRuns, 3);
    val_error_SIM = zeros(length(numTrExVec), numAvgRuns, 3);
    gen_error = zeros(length(numTrExVec), numAvgRuns, 3);
    gen_error_SIM = zeros(length(numTrExVec), numAvgRuns, 3);
    numSuppVec = zeros(length(numTrExVec), numAvgRuns, 3);
    numSuppVec_SIM = zeros(length(numTrExVec), numAvgRuns, 3);

    boxConstraints = zeros(3, 1);
    boxConstraints_SIM = zeros(3, 1);
    
    % loop over different grids
    for idx_grid = 1:3

        [X_train, X_train_SIM, y_train, X_test, X_test_SIM, y_test] = selectGrid(idx_grid, data);

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
        parfor j = 1:length(numTrExVec)

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

                % Do SVM predictions on train set and store training error
                SVMLabel_train = predict(SVMModel, X);
                SVMLabel_SIM_train = predict(SVMModel_SIM, X_SIM);
                train_error(j, k, idx_grid) = sum(abs(SVMLabel_train - y)) / length(y);
                train_error_SIM(j, k, idx_grid) = sum(abs(SVMLabel_SIM_train - y)) / length(y);

                % Store validation error
                val_error(j, k, idx_grid) = min(SVMModel.HyperparameterOptimizationResults.Objective);
                val_error_SIM(j, k, idx_grid) = min(SVMModel_SIM.HyperparameterOptimizationResults.Objective);

                % Do SVM predictions on test set and store generalization error
                SVMLabel = predict(SVMModel, X_test);
                SVMLabel_SIM = predict(SVMModel_SIM, X_test_SIM);
                gen_error(j, k, idx_grid) = sum(abs(SVMLabel - y_test)) / length(y_test);
                gen_error_SIM(j, k, idx_grid) = sum(abs(SVMLabel_SIM - y_test)) / length(y_test);

                % SVM calculate number of support vectors
                numSuppVec(j, k, idx_grid) = length(SVMModel.SupportVectorLabels);
                numSuppVec_SIM(j, k, idx_grid) = length(SVMModel_SIM.SupportVectorLabels);

            end

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

    experimentPars.boxConstraints = boxConstraints;
    experimentPars.boxConstraints_SIM = boxConstraints_SIM;

    % save experiment input and settings
    results.data = data;
    results.experimentPars = experimentPars;
    
    outcomes.SVM = SVM_outcomes;
    outcomes.SVM_SIM = SVM_outcomes_SIM;
    
    results.outcomes = outcomes;

end

function [X_train, X_train_Phi, y_train, X_test, X_test_Phi, y_test] = selectGrid(idx_grid, data)

    % Return experimental data on chosen grid (1 -> dense grid, 2 -> sparse grid, 3 -> irregular grid)

    if idx_grid == 1
    
        % Extract training data
        X_train = [data.dense.mleDataTrain.observations.MLE_theta]';
        X_train_Phi = [data.dense.mleDataTrain.observations.MLE_Phi]';
        y_train = [data.dense.mleDataTrain.observations.label]';

        % Extract test data from data set
        X_test = [data.dense.mleDataTest.observations.MLE_theta]';
        X_test_Phi = [data.dense.mleDataTest.observations.MLE_Phi]';
        y_test = [data.dense.mleDataTest.observations.label]';
    
    elseif idx_grid == 2
    
        % Extract training data
        X_train = [data.sparse.mleDataTrain.observations.MLE_theta]';
        X_train_Phi = [data.sparse.mleDataTrain.observations.MLE_Phi]';
        y_train = [data.sparse.mleDataTrain.observations.label]';

        % Extract test data from data set
        X_test = [data.sparse.mleDataTest.observations.MLE_theta]';
        X_test_Phi = [data.sparse.mleDataTest.observations.MLE_Phi]';
        y_test = [data.sparse.mleDataTest.observations.label]';

    else
        
        % Extract training data
        X_train = [data.irr.mleDataTrain.observations.MLE_theta]';
        X_train_Phi = [data.irr.mleDataTrain.observations.MLE_Phi]';
        y_train = [data.irr.mleDataTrain.observations.label]';

        % Extract test data from data set
        X_test = [data.irr.mleDataTest.observations.MLE_theta]';
        X_test_Phi = [data.irr.mleDataTest.observations.MLE_Phi]';
        y_test = [data.irr.mleDataTest.observations.label]';
    
    end

end