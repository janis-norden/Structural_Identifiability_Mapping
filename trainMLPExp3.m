function results = trainMLPExp3(data, experimentPars, imputation_mode)
    
    % Train Multi-Layer Perceptron (MLP) on time series for different amounts of data.
    % Imputation strategy is either Gaussian process or linear regression
    
    % Extract number of noise levels from data set
    numTrExVec = experimentPars.numTrExVec;
    numAvgRuns = experimentPars.numAvgRuns;

    NumGridDivisions = experimentPars.NumGridDivisions;
    Kfold = experimentPars.Kfold;
    
    % Initialize outcomes structures
    train_error = zeros(length(numTrExVec), numAvgRuns, 3);
    gen_error = zeros(length(numTrExVec), numAvgRuns, 3);
    
    % loop over different grids
    for idx_grid = 1:3

        [X_train, y_train, X_test, y_test] = selectGrid(idx_grid, data, imputation_mode);

        % find all indices associated with class 0 and 1
        idx_C0 = find(y_train == 0);
        idx_C1 = find(y_train == 1);

        hyper_params = hyperparameters('fitcnet', X_train, y_train);

        hyper_params(1).Optimize = false;       % turn off optimization for number of layers
        hyper_params(2).Optimize = false;       % turn off optimization of choice of activation function
        hyper_params(3).Optimize = false;       % turn off optimization of normalization

        % Loop over different amounts of training data
        parfor j = 1:length(numTrExVec)

            % Averaging runs
            for k = 1:numAvgRuns

                % draw numTrExVec(j) training examples from both classes
                idx_select_C0 = randsample(idx_C0, numTrExVec(j));
                idx_select_C1 = randsample(idx_C1, numTrExVec(j));
                idx_select = [idx_select_C0; idx_select_C1];

                X = X_train(idx_select, :);
                y = y_train(idx_select);

                % -------------Train MLP-------------
                MLPModel = fitcnet(X, y, 'Standardize', true, 'Activations', 'sigmoid', 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'bayesopt', 'NumGridDivisions', NumGridDivisions, 'Kfold', Kfold, 'MaxTime', 20), OptimizeHyperparameters = hyper_params);

                % Do MLP predictions on train set and store training error
                MLPLabel_train = predict(MLPModel, X);
                train_error(j, k, idx_grid) = sum(abs(MLPLabel_train - y)) / length(y);

                % Do MLP predictions on test set and store generalization error
                MLPLabel_test = predict(MLPModel, X_test);
                gen_error(j, k, idx_grid) = sum(abs(MLPLabel_test - y_test)) / length(y_test);

            end

        end
        
    end

    % collect outcomes in structs
    MLP_outcomes.train_error = train_error;
    MLP_outcomes.gen_error = gen_error;
    
    % save experiment input and settings
    results.data = data;
    results.experimentPars = experimentPars;

    outcomes.MLP = MLP_outcomes;
    
    results.outcomes = outcomes;

end

function [X_train, y_train, X_test, y_test] = selectGrid(idx_grid, data, imputation_mode)

    % Return experimental data on chosen grid (1 -> dense grid, 2 -> sparse grid, 3 -> irregular grid)
    if idx_grid == 1
        
        data_grid = data.dense;
        needs_imputation = 0;

    elseif idx_grid == 2
        
        data_grid = data.sparse;
        needs_imputation = 0;

    else
        
        data_grid = data.irr;
        needs_imputation = 1;

    end

    % extract training and test labels
    y_train = [data_grid.mleDataTrain.observations.label]';
    y_test = [data_grid.mleDataTest.observations.label]';
    
    % extract number of training and test examples
    n_examples_train = length(y_train);
    n_examples_test = length(y_test);

    % check if time series need to be imputed
    if needs_imputation == 0

        % extract number of time points (does not change for dense and sparse grids)
        numTimepoints = size(data_grid.mleDataTrain.observations(1).timeseries, 2);

        % extract training and test data
        X_train = zeros(n_examples_train, numTimepoints);
        X_test = zeros(n_examples_test, numTimepoints);
        for idx_example = 1:n_examples_train
            
            % extract time series and add padding if needed
            X_train(idx_example, :) = data_grid.mleDataTrain.observations(idx_example).timeseries(2, :);
        
        end
        for idx_example = 1:n_examples_test
    
            % extract time series and add padding if needed
            X_test(idx_example, :) = data_grid.mleDataTest.observations(idx_example).timeseries(2, :);
        end
        
    else

        if strcmp(imputation_mode, 'gaussian_process')
        
            % define times where to impute values
            tEval = data.dataGenPars.obsMode.t';
    
            % extract training and test data
            X_train = zeros(n_examples_train, length(tEval));
            X_test = zeros(n_examples_test, length(tEval));
            parfor idx_example = 1:n_examples_train
                
                % extract timeseries
                tObs = data_grid.mleDataTrain.observations(idx_example).timeseries(1, :)';
                yObs = data_grid.mleDataTrain.observations(idx_example).timeseries(2, :)';
                
                % define hyperparameters to be optimized
                hyper_params = hyperparameters('fitrgp', tObs, yObs);
                hyper_params(5).Optimize = false;   % turn off optimization of Standardize
                
                % fit Gaussian process regression model
                GPModel = fitrgp(tObs, yObs, 'KernelFunction','squaredexponential', 'Standardize', true, 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'bayesopt', 'Kfold', 2, 'MaxTime', 20), OptimizeHyperparameters = hyper_params);
                
                % predict values on tEval using Gaussian process model
                yPredicted = predict(GPModel, tEval);
    
                % add imputed values to feature matrix
                X_train(idx_example, :) = yPredicted';
            
            end
            parfor idx_example = 1:n_examples_test
        
                % extract timeseries
                tObs = data_grid.mleDataTest.observations(idx_example).timeseries(1, :)';
                yObs = data_grid.mleDataTest.observations(idx_example).timeseries(2, :)';
                
                % define hyperparameters to be optimized
                hyper_params = hyperparameters('fitrgp', tObs, yObs);
                hyper_params(5).Optimize = false;   % turn off optimization of Standardize
                
                % fit Gaussian process regression model
                GPModel = fitrgp(tObs, yObs, 'KernelFunction','squaredexponential', 'Standardize', true, 'HyperparameterOptimizationOptions', struct('UseParallel', false, 'ShowPlots', false, 'Verbose', 0, 'Optimizer', 'bayesopt', 'Kfold', 3, 'MaxTime', 20), OptimizeHyperparameters = hyper_params);
                
                % predict values on tEval using Gaussian process model
                yPredicted = predict(GPModel, tEval);
    
                % add imputed values to feature matrix
                X_test(idx_example, :) = yPredicted';
            end

        elseif strcmp(imputation_mode, 'linear_regression')
            
            % define times where to impute values
            tEval = data.dataGenPars.obsMode.t';
    
            % loop over training examples
            X_train = zeros(n_examples_train, length(tEval));
            for idx_example = 1:n_examples_train
                
                % extract timeseries
                tObs = data_grid.mleDataTrain.observations(idx_example).timeseries(1, :)';
                yObs = data_grid.mleDataTrain.observations(idx_example).timeseries(2, :)';
                
                % create matrix of constants and linear terms
                xObs = [ones(length(tObs), 1), tObs];

                % solve for regression coefficients and make predictions
                b = xObs \ yObs;
                yPredicted = b(1) + b(2) * tEval;

                % add imputed values to feature matrix
                X_train(idx_example, :) = yPredicted';

            end
            
            % loop over test examples
            X_test = zeros(n_examples_test, length(tEval));
            for idx_example = 1:n_examples_test
                
                % extract timeseries
                tObs = data_grid.mleDataTest.observations(idx_example).timeseries(1, :)';
                yObs = data_grid.mleDataTest.observations(idx_example).timeseries(2, :)';
                
                % create matrix of constants and linear terms
                xObs = [ones(length(tObs), 1), tObs];

                % solve for regression coefficients and make predictions
                b = xObs \ yObs;
                yPredicted = b(1) + b(2) * tEval;

                % add imputed values to feature matrix
                X_test(idx_example, :) = yPredicted';

            end

        else
            
            % print error message if choice of imputation strategy is
            % invalid
            fprintf('Invalid choice of imputation strategy. \n')

        end
    end

end

function [X_train, y_train, X_test, y_test] = selectGridPadding(idx_grid, data)

    % Return experimental data on chosen grid (1 -> dense grid, 2 -> sparse grid, 3 -> irregular grid)

    if idx_grid == 1

        data_grid = data.dense;
       
    elseif idx_grid == 2

        data_grid = data.sparse;

    else
        data_grid = data.irr;
        
    end

    % extract training and test labels
    y_train = [data_grid.mleDataTrain.observations.label]';
    y_test = [data_grid.mleDataTest.observations.label]';
    
    % extract number of training and test examples
    n_examples_train = length(y_train);
    n_examples_test = length(y_test);
    
    % --- find longest timeseries in training and test data ---
    numTimepointsTrain = zeros(n_examples_train, 1);
    numTimepointsTest = zeros(n_examples_test, 1);
    for idx_example = 1:n_examples_train
        
        % find number of timepoints in current example
        numTimepointsTrain(idx_example) = size(data_grid.mleDataTrain.observations(idx_example).timeseries, 2);
    
    end
    for idx_example = 1:n_examples_test
        
        % find number of timepoints in current example
        numTimepointsTest(idx_example) = size(data_grid.mleDataTest.observations(idx_example).timeseries, 2);
    
    end
    maxNumTimepoints = max([numTimepointsTrain; numTimepointsTest]);
    
    % --- extract training and test data with zero-padding ---
    X_train = zeros(n_examples_train, maxNumTimepoints);
    X_test = zeros(n_examples_test, maxNumTimepoints);
    for idx_example = 1:n_examples_train
        
        % extract time series and add padding if needed
        numTimepoints = size(data_grid.mleDataTrain.observations(idx_example).timeseries, 2);
        X_train(idx_example, (maxNumTimepoints - numTimepoints + 1):end) = data_grid.mleDataTrain.observations(idx_example).timeseries(2, :);
    
    end
    for idx_example = 1:n_examples_test

        % extract time series and add padding if needed
        numTimepoints = size(data_grid.mleDataTest.observations(idx_example).timeseries, 2);
        X_test(idx_example, (maxNumTimepoints - numTimepoints + 1):end) = data_grid.mleDataTest.observations(idx_example).timeseries(2, :);
    end

end