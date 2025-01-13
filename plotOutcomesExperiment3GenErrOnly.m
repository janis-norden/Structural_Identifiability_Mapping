function fig = plotOutcomesExperiment3GenErrOnly(resultsUID, options)
    % DESCRIPTION: Plots the outcomes of experiment 3.

    % INPUT:
    % resultsUID:  struct containing the results of experiment 3 for the UID model
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

    % Extract experiment info
    numTrExVec = resultsUID.experimentPars.numTrExVec;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    blue = [0 0.4470 0.7410];
    orange = [0.8500 0.3250 0.0980];
    green = [0.4660 0.6740 0.1880];

    if options.plotStyle.fullscreen == 1
        fig = figure('units','normalized','outerposition',[0 0 1 1]);
    else
        fig = figure(1);
        clf(fig);
        set(fig,'units','centimeters','color','white','position',options.plotStyle.figuresize,'PaperPositionMode','auto');
    end
    
    tiledlayout(1, 3, 'Padding', 'none', 'TileSpacing', 'loose'); 

   
    % Plot generalization error on dense grid
    nexttile;
    hold on

    errorbar(numTrExVec, mean(genError_UID(:, :, 1), 2), std(genError_UID(:, :, 1), 0, 2), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_UID_SIM(:, :, 1), 2), std(genError_UID_SIM(:, :, 1), 0, 2), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)
    
    xlim(options.xLimits)
    ylim(options.yLimits_errors)
    xlabel('\# training examples per class', 'Interpreter','latex')
    ylabel('gen. error', 'Interpreter','latex')

    % add legend
    lgd = legend('PO model', 'PO model + SIM', 'Location', 'northeast', 'Interpreter', 'latex');
    fontsize(lgd, options.plotStyle.legend_font_size, 'points')

    title_strg = 'a) Dense grid';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize', axes_font_size)

    % Plot generalization error on sparse grid
    nexttile
    hold on

    errorbar(numTrExVec, mean(genError_UID(:, :, 2), 2), std(genError_UID(:, :, 2), 0, 2), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_UID_SIM(:, :, 2), 2), std(genError_UID_SIM(:, :, 2), 0, 2), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim(options.yLimits_errors)
    xlabel('\# training examples per class', 'Interpreter','latex')
    ylabel('gen. error', 'Interpreter','latex')
   
    title_strg = 'b) Sparse grid';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % Plot generalization error on irregular grid
    nexttile
    hold on
    
    errorbar(numTrExVec, mean(genError_UID(:, :, 3), 2), std(genError_UID(:, :, 3), 0, 2), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_UID_SIM(:, :, 3), 2), std(genError_UID_SIM(:, :, 3), 0, 2), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim(options.yLimits_errors)
    xlabel('\# training examples per class', 'Interpreter','latex')
    ylabel('gen. error', 'Interpreter','latex')
    
    title_strg = 'c) Irregular grid';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % set fontype
    set(findall(gcf,'-property','FontName'),'FontName',options.plotStyle.fontname)
end