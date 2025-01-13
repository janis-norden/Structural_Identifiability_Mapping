function results = trainLDAExp1(data, experimentPars)
    
    % DESCRIPTION: Train LDA classifiers on original and preprocessed data
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
    % hyper_params = hyperparameters('fitcdiscr', X_train, y_train);
    
    % hyper_params(1).Range = [10^-3, 200];   % BoxConstraint           
    % hyper_params(1).Transform = 'none';
    % 
    % hyper_params(2).Range = [1, 50];   % kernelScale              
    % hyper_params(2).Transform = 'none';
    % 
    % hyper_params(5).Optimize = false;       % turn off optimization for standardization

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
            LDAModel = fitcdiscr(X, y, 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', NumGridDivisions, 'Kfold', Kfold), OptimizeHyperparameters = {'Delta','Gamma'});
            LDAModel_SIM = fitcdiscr(X_SIM, y, 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'gridsearch', 'NumGridDivisions', NumGridDivisions, 'Kfold', Kfold), OptimizeHyperparameters = {'Delta','Gamma'});

            % Do SVM predictions on train set and store training error
            LDALabel_train = predict(LDAModel, X);
            LDALabel_SIM_train = predict(LDAModel_SIM, X_SIM);
            train_error(j, k) = sum(abs(LDALabel_train - y)) / length(y);
            train_error_SIM(j, k) = sum(abs(LDALabel_SIM_train - y)) / length(y);

            % Store validation error
            val_error(j, k) = min(LDAModel.HyperparameterOptimizationResults.Objective);
            val_error_SIM(j, k) = min(LDAModel_SIM.HyperparameterOptimizationResults.Objective);

            % Do SVM predictions on test set and store generalization error
            LDALabel = predict(LDAModel, X_test);
            LDALabel_SIM = predict(LDAModel_SIM, X_test_SIM);
            gen_error(j, k) = sum(abs(LDALabel - y_test)) / length(y_test);
            gen_error_SIM(j, k) = sum(abs(LDALabel_SIM - y_test)) / length(y_test);

        end

    end

    % collect outcomes in structs
    LDA_outcomes.train_error = train_error;
    LDA_outcomes_SIM.train_error = train_error_SIM;

    LDA_outcomes.val_error = val_error;
    LDA_outcomes_SIM.val_error = val_error_SIM;

    LDA_outcomes.gen_error = gen_error;
    LDA_outcomes_SIM.gen_error = gen_error_SIM;

    % save experiment input and settings
    results.data = data;
    results.experimentPars = experimentPars;
    
    outcomes.LDA = LDA_outcomes;
    outcomes.LDA_SIM = LDA_outcomes_SIM;
    
    results.outcomes = outcomes;

end