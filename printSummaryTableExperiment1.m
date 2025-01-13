function printSummaryTableExperiment1(filenames_results, options)
    
    % DESCRIPTION: Prints experiment 1 summary table to command line so it may be copied into a LaTeX table easily.

    % INPUT:
    % filenames_results:  struct containing the filenames of experiment 1 results saved in folder 'Results/' associated with each of the example models
    % options:            struct containing options relating to command-line printing

    % extract formatting specifications from options
    fspec = options.formatSpec;

    % extract all field names from filenames_results
    fn = fieldnames(filenames_results);
    
    % display header
    disp('--- Experiment 1 ---')

    % loop over each example system
    for i=1:length(fn)

        % load experimental outcomes for current system
        results = load(strcat('Results/', filenames_results.(fn{i}), '.mat'));
        results_ID_SVM  = results.results_ID_SVM;
        results_UID_SVM = results.results_UID_SVM;

        % find minimum and maximum number of training examples
        numTrainMin = results_ID_SVM.experimentPars.numTrExVec(1);
        numTrainMax = results_ID_SVM.experimentPars.numTrExVec(end);

        % ID system: find mean generalization error and std. and extract values at N_{min} and N_{max}
        meansErrorID = mean(results_ID_SVM.outcomes.SVM.gen_error, 2);
        stdsErrorID = std(results_ID_SVM.outcomes.SVM.gen_error, 0, 2);
        minMeanErrorID = meansErrorID(1);
        maxMeanErrorID = meansErrorID(end);
        minStdErrorID = stdsErrorID(1);
        maxStdErrorID = stdsErrorID(end);

        % UID system: find mean generalization error and std. and extract values at N_{min} and N_{max}
        meansErrorUID = mean(results_UID_SVM.outcomes.SVM.gen_error, 2);
        stdsErrorUID = std(results_UID_SVM.outcomes.SVM.gen_error, 0, 2);
        minMeanErrorUID = meansErrorUID(1);
        maxMeanErrorUID = meansErrorUID(end);
        minStdErrorUID = stdsErrorUID(1);
        maxStdErrorUID = stdsErrorUID(end);

        % UID system: find mean generalization error and std. and extract values at N_{min} and N_{max}
        meansErrorUID_SIM = mean(results_UID_SVM.outcomes.SVM_SIM.gen_error, 2);
        stdsErrorUID_SIM = std(results_UID_SVM.outcomes.SVM_SIM.gen_error, 0, 2);
        minMeanErrorUID_SIM = meansErrorUID_SIM(1);
        maxMeanErrorUID_SIM = meansErrorUID_SIM(end);
        minStdErrorUID_SIM = stdsErrorUID_SIM(1);
        maxStdErrorUID_SIM = stdsErrorUID_SIM(end);

        % print LaTeX code to command line
        disp(strrep([fn{i}, ' & ', num2str(numTrainMin), ' & ' num2str(numTrainMax), ' & ', ...
            num2str(minMeanErrorID, fspec), ' (', num2str(minStdErrorID, fspec) ')', ' & ', num2str(minMeanErrorUID, fspec), ' (', num2str(minStdErrorUID, fspec) ')',  ' & ', num2str(minMeanErrorUID_SIM, fspec), ' (', num2str(minStdErrorUID_SIM, fspec) ')',  ' & ', ...
            num2str(maxMeanErrorID, fspec), ' (', num2str(maxStdErrorID, fspec) ')', ' & ', num2str(maxMeanErrorUID, fspec), ' (', num2str(maxStdErrorUID, fspec) ')',  ' & ', num2str(maxMeanErrorUID_SIM, fspec), ' (', num2str(maxStdErrorUID_SIM, fspec) ')', ' \\'], '0.', '.'))
        
    end

end