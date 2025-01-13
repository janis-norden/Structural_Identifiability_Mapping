function printSummaryTableExperiment3(filenames_results, options)
    
    % DESCRIPTION: Prints experiment 3 summary table to command line so it may be copied into a LaTeX table easily.

    % INPUT:
    % filenames_results:  struct containing the filenames of experiment 3 results saved in folder 'Results/' associated with each of the example models
    % options:            struct containing options relating to command-line printing

    % extract formatting specifications from options
    fspec = options.formatSpec;

    % extract all field names from filenames_results
    fn = fieldnames(filenames_results);
    
    % display header
    disp('--- Experiment 3 ---')

    % loop over each example system
    for i=1:length(fn)

        % load experimental outcomes for current system
        results = load(strcat('Results/', filenames_results.(fn{i}), '.mat'));
        
        % find minimum and maximum number of training examples
        numTrainMin = results.resultsUID.experimentPars.numTrExVec(1);

        % dense grid: find mean generalization error for ID and UID systems
        meansErrorUIDDense = mean(results.resultsUID.outcomes.SVM.gen_error(:, :, 1), 2);
        stdErrorUIDDense = std(results.resultsUID.outcomes.SVM.gen_error(:, :, 1), 0, 2);
        meansErrorUIDSIMDense = mean(results.resultsUID.outcomes.SVM_SIM.gen_error(:, :, 1), 2);
        stdErrorUIDSIMDense = std(results.resultsUID.outcomes.SVM_SIM.gen_error(:, :, 1), 0, 2);
        minMeansErrorUIDDense = meansErrorUIDDense(1);
        minStdErrorUIDDense = stdErrorUIDDense(1);
        minMeansErrorUIDSIMDense = meansErrorUIDSIMDense(1);
        minStdErrorUIDSIMDense = stdErrorUIDSIMDense(1);
        
        % sparse grid: find mean generalization error for ID and UID systems
        meansErrorUIDSparse = mean(results.resultsUID.outcomes.SVM.gen_error(:, :, 2), 2);
        stdErrorUIDSparse = std(results.resultsUID.outcomes.SVM.gen_error(:, :, 2), 0, 2);
        meansErrorUIDSIMSparse = mean(results.resultsUID.outcomes.SVM_SIM.gen_error(:, :, 2), 2);
        stdErrorUIDSIMSparse = std(results.resultsUID.outcomes.SVM_SIM.gen_error(:, :, 2), 0, 2);
        minMeansErrorUIDSparse = meansErrorUIDSparse(1);
        minStdErrorUIDSparse = stdErrorUIDSparse(1);
        minMeansErrorUIDSIMSparse = meansErrorUIDSIMSparse(1);
        minStdErrorUIDSIMSparse = stdErrorUIDSIMSparse(1);
        
        % irregular grid: find mean generalization error for ID and UID systems
        meansErrorUIDIrr = mean(results.resultsUID.outcomes.SVM.gen_error(:, :, 3), 2);
        stdErrorUIDIrr = std(results.resultsUID.outcomes.SVM.gen_error(:, :, 3), 0, 2);
        meansErrorUIDSIMIrr = mean(results.resultsUID.outcomes.SVM_SIM.gen_error(:, :, 3), 2);
        stdErrorUIDSIMIrr = std(results.resultsUID.outcomes.SVM_SIM.gen_error(:, :, 3), 0, 2);
        minMeansErrorUIDIrr = meansErrorUIDIrr(1);
        minStdErrorUIDIrr = stdErrorUIDIrr(1);
        minMeansErrorUIDSIMIrr = meansErrorUIDSIMIrr(1);
        minStdErrorUIDSIMIrr = stdErrorUIDSIMIrr(1);

        % print LaTeX code to command line
        disp(strrep([fn{i}, ' & ', ...
            num2str(minMeansErrorUIDDense, fspec), ' (', num2str(minStdErrorUIDDense, fspec) ')', ' & ', ...
            num2str(minMeansErrorUIDSIMDense, fspec), ' (', num2str(minStdErrorUIDSIMDense, fspec) ')',  ' & ', ...
            num2str(minMeansErrorUIDSparse, fspec), ' (', num2str(minStdErrorUIDSparse, fspec) ')',  ' & ', ...
            num2str(minMeansErrorUIDSIMSparse, fspec), ' (', num2str(minStdErrorUIDSIMSparse, fspec) ')', ' & ', ...
            num2str(minMeansErrorUIDIrr, fspec), ' (', num2str(minStdErrorUIDIrr, fspec) ')',  ' & ', ...
            num2str(minMeansErrorUIDSIMIrr, fspec), ' (', num2str(minStdErrorUIDSIMIrr, fspec) ')', ' \\'], '0.', '.'))
        
    end

end