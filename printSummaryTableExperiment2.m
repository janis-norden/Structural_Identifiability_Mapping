function printSummaryTableExperiment2(filenames_results, options)
    
    % DESCRIPTION: Prints experiment 2 summary table to command line so it may be copied into a LaTeX table easily.

    % INPUT:
    % filenames_results:  struct containing the filenames of experiment 2 results saved in folder 'Results/' associated with each of the example models
    % options:            struct containing options relating to command-line printing

    % extract formatting specifications from options
    fspec = options.formatSpec;

    % extract all field names from filenames_results
    fn = fieldnames(filenames_results);
    
    % display header
    disp('--- Experiment 2 ---')

    % loop over each example system
    for i=1:length(fn)

        % load experimental outcomes for current system
        results = load(strcat('Results/', filenames_results.(fn{i}), '.mat'));
        
        % extract number of examples used and observational noise vector
        numExUsed = results.resultsUID.experimentPars.numExUsed;
        sigmaObsVec = results.resultsUID.data.dataGenPars.sigmaObsVec;

        % find mean generalization error at every level of obs. noise
        meansErrorUID = mean(results.resultsUID.outcomes.SVM.gen_error, 2);
        meansErrorUID_SIM = mean(results.resultsUID.outcomes.SVM_SIM.gen_error, 2);

        % find average of differences
        meanDiff = mean(meansErrorUID - meansErrorUID_SIM);
        
        % find max of differences
        [maxDiff, maxIdx] = max(meansErrorUID - meansErrorUID_SIM);

        % print LaTeX code to command line
        disp(strrep([fn{i}, ' & ', num2str(numExUsed, '%i'), ' & ', num2str(sigmaObsVec(maxIdx), fspec), ' & ' num2str(maxDiff, fspec), ' & ', num2str(meanDiff, fspec), ' \\'], '0.', '.'))
        
    end

end