function fig = plotOutcomesExperiment2(resultsUID, options)
    % DESCRIPTION: Plots the outcomes of experiment 2.

    % INPUT:
    % resultsUID:  struct containing the results of experiment 2 for the UID model
    % options:     struct containing options relating to figure design
    
    % OUTPUT:           
    % fig:         fig MATLAB figure containig the created plot

    % Extract plot styles
    linestyle_UID = options.plotStyle.linestyle_UID;
    linestyle_UID_SIM = options.plotStyle.linestyle_UID_SIM;
    linestyle_width = options.plotStyle.linestyle_width;
    axes_font_size = options.plotStyle.axes_font_size;

    % Unpack training errors
    genError_UID = resultsUID.outcomes.SVM.gen_error;
    genError_UID_SIM = resultsUID.outcomes.SVM_SIM.gen_error;

    % Unpack #supp vectors
    suppVec_UID = resultsUID.outcomes.SVM.numSuppVec;
    suppVec_UID_SIM = resultsUID.outcomes.SVM_SIM.numSuppVec;

    % Extract experiment info
    numExUsed = resultsUID.experimentPars.numExUsed;
    sigmaObsVec = resultsUID.data.dataGenPars.sigmaObsVec;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    blue = [0 0.4470 0.7410];
    orange = [0.8500 0.3250 0.0980];
    %green = [0.4660 0.6740 0.1880];

    if options.plotStyle.fullscreen == 1
        fig = figure('units','normalized','outerposition',[0 0 1 1]);
    else
        fig = figure(1);
        clf(fig);
        set(fig,'units','centimeters','color','white','position',options.plotStyle.figuresize,'PaperPositionMode','auto');
    end
    
    tiledlayout(2, 1, 'Padding', 'none', 'TileSpacing', 'loose');

    % Plot generalization error
    nexttile
    hold on

    errorbar(sigmaObsVec, mean(genError_UID, 2), std(genError_UID, 0, 2), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(sigmaObsVec, mean(genError_UID_SIM, 2), std(genError_UID_SIM, 0, 2), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim(options.yLimits_errors)
    xlabel('observational noise $\sigma$','Interpreter','latex')
    ylabel('gen. error', 'Interpreter','latex')

    % add legend
    lgd = legend('PO model', 'PO model + SIM', 'Location','southeast','Interpreter','latex');
    fontsize(lgd, options.plotStyle.legend_font_size, 'points')
   
    title_strg = 'a) Generalisation error';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % Plot # of support vectors
    nexttile
    hold on

    errorbar(sigmaObsVec, mean(suppVec_UID ./ (2 * numExUsed), 2), std(suppVec_UID ./ (2 * numExUsed), 0, 2), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(sigmaObsVec, mean(suppVec_UID_SIM ./ (2 * numExUsed), 2), std(suppVec_UID_SIM ./ (2 * numExUsed), 0, 2), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim([0 1])
    xlabel('observational noise $\sigma$','Interpreter','latex')
    ylabel('ratio', 'Interpreter','latex')
    
    title_strg = 'b) Relative \# support vectors';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % set fontype
    set(findall(gcf,'-property','FontName'),'FontName',options.plotStyle.fontname)
end