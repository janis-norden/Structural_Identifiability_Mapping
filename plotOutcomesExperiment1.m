function fig = plotOutcomesExperiment1(resultsID, resultsUID, options)
    % DESCRIPTION: Plots the outcomes of experiment 1.

    % INPUT:
    % resultsID:   struct containing the results of experiment 1 for the ID model
    % resultsUID:  struct containing the results of experiment 1 for the UID model
    % options:     struct containing options relating to figure design
    
    % OUTPUT:           
    % fig:         fig MATLAB figure containig the created plot


    % NOTE: ResultsID and ResultsUID need to be obtained from runs with the 
    % same experimental conditions

    % Extract plot styles
    linestyle_ID = options.plotStyle.linestyle_ID;
    linestyle_UID = options.plotStyle.linestyle_UID;
    linestyle_UID_SIM = options.plotStyle.linestyle_UID_SIM;
    linestyle_width = options.plotStyle.linestyle_width;
    axes_font_size = options.plotStyle.axes_font_size;

    % Unpack training errors
    genError_ID = resultsID.outcomes.SVM.gen_error;
    genError_UID = resultsUID.outcomes.SVM.gen_error;
    genError_UID_SIM = resultsUID.outcomes.SVM_SIM.gen_error;

    % Unpack #supp vectors
    suppVec_ID = resultsID.outcomes.SVM.numSuppVec;
    suppVec_UID = resultsUID.outcomes.SVM.numSuppVec;
    suppVec_UID_SIM = resultsUID.outcomes.SVM_SIM.numSuppVec;

    % Extract experiment info
    numTrExVec = resultsID.experimentPars.numTrExVec;
    numAvgRuns = resultsID.experimentPars.numAvgRuns;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    blue = [0 0.4470 0.7410];
    orange = [0.8500 0.3250 0.0980];
    green = [0.4660 0.6740 0.1880];

    if options.plotStyle.fullscreen == 1
        fig = figure('units','normalized','outerposition',[0 0 1 1]);
    else
        fig = figure;
        clf(fig);
        set(fig,'units','centimeters','color','white','position',options.plotStyle.figuresize,'PaperPositionMode','auto');
    end
    
    tiledlayout(2, 1, 'Padding', 'none', 'TileSpacing', 'loose'); 

    % Plot generalization error
    nexttile
    hold on

    errorbar(numTrExVec, mean(genError_ID, 2), std(genError_ID, 0, 2), Color=green, LineStyle=linestyle_ID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_UID, 2), std(genError_UID, 0, 2), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_UID_SIM, 2), std(genError_UID_SIM, 0, 2), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim(options.yLimits_errors)
    xlabel('\# training examples per class', 'Interpreter','latex')
    ylabel('gen. error', 'Interpreter','latex')

    % add legend
    lgd = legend('FO model', 'PO model', 'PO model + SIM', 'Location','northeast','Interpreter','latex');
    fontsize(lgd, options.plotStyle.legend_font_size, 'points')
   
    title_strg = 'a) Generalisation error';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % Plot # of support vectors
    nexttile
    hold on

    errorbar(numTrExVec, mean(suppVec_ID ./ repmat(2 * numTrExVec', 1, numAvgRuns) , 2), std(suppVec_ID ./ repmat(2 * numTrExVec', 1, numAvgRuns), 0, 2), Color=green, LineStyle=linestyle_ID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(suppVec_UID ./ repmat(2 * numTrExVec', 1, numAvgRuns), 2), std(suppVec_UID ./ repmat(2 * numTrExVec', 1, numAvgRuns), 0, 2), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(suppVec_UID_SIM ./ repmat(2 * numTrExVec', 1, numAvgRuns), 2), std(suppVec_UID_SIM ./ repmat(2 * numTrExVec', 1, numAvgRuns), 0, 2), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim([0 1])
    xlabel('\# training examples per class', 'Interpreter','latex')
    ylabel('ratio', 'Interpreter','latex')
    
    title_strg = 'b) Relative \# support vectors';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % set fontype
    set(findall(gcf,'-property','FontName'),'FontName',options.plotStyle.fontname)
end