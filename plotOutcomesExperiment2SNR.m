function fig = plotOutcomesExperiment2SNR(resultsUID, options)
    % NOTE: ResultsID and ResultsUID need to be obtained from runs with the 
    % same experimental conditions

    % Extract plot styles
    linestyle_UID = options.plotStyle.linestyle_UID;
    linestyle_UID_SIM = options.plotStyle.linestyle_UID_SIM;
    linestyle_width = options.plotStyle.linestyle_width;
    axes_font_size = options.plotStyle.axes_font_size;
    legend_location = options.plotStyle.legend_location;

    % Unpack training errors
    genError_UID = resultsUID.outcomes.SVM.gen_error;
    genError_UID_SIM = resultsUID.outcomes.SVM_SIM.gen_error;

    % Unpack #supp vectors
    suppVec_UID = resultsUID.outcomes.SVM.numSuppVec;
    suppVec_UID_SIM = resultsUID.outcomes.SVM_SIM.numSuppVec;

    [genError_UID_trim, suppVec_UID_trim] = remove_outliers(genError_UID, suppVec_UID);
    [genError_UID_SIM_trim, suppVec_UID_SIM_trim] = remove_outliers(genError_UID_SIM, suppVec_UID_SIM);

    % Extract experiment info
    numExUsed = resultsUID.experimentPars.numExUsed;
    %sigmaObsVec = resultsUID.data.dataGenPars.sigmaObsVec;
    SNRVec = resultsUID.data.dataGenPars.SNRVec;
    
    SNRVecPlot = log10(SNRVec);

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

    errorbar(SNRVecPlot, mean(genError_UID_trim, 2, 'omitnan'), std(genError_UID_trim, 0, 2, 'omitnan'), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(SNRVecPlot, mean(genError_UID_SIM_trim, 2, 'omitnan'), std(genError_UID_SIM_trim, 0, 2, 'omitnan'), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim(options.yLimits_errors)
    
    xticks(0:0.5:4)
    xticklabels({'10^{0}', '', '10^{1}', '','10^{2}', '', '10^{3}', '', '10^{4}'})
    yticks([0, 0.1, 0.2, 0.3, 0.4, 0.5])

    xlabel('signal-to-noise ratio','Interpreter','latex')
    ylabel('gen. error', 'Interpreter','latex')

    % add legend
    lgd = legend('PO model', 'PO model + SIM', 'Location',legend_location,'Interpreter','latex');
    fontsize(lgd, options.plotStyle.legend_font_size, 'points')
   
    title_strg = 'a) Generalisation error';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % Plot # of support vectors
    nexttile
    hold on

    errorbar(SNRVecPlot, mean(suppVec_UID_trim ./ (2 * numExUsed), 2, 'omitnan'), std(suppVec_UID_trim ./ (2 * numExUsed), 0, 2, 'omitnan'), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(SNRVecPlot, mean(suppVec_UID_SIM_trim ./ (2 * numExUsed), 2, 'omitnan'), std(suppVec_UID_SIM_trim ./ (2 * numExUsed), 0, 2, 'omitnan'), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

    xlim(options.xLimits)
    ylim([0 1])
    
    xticks(0:0.5:4)
    xticklabels({'10^{0}', '', '10^{1}', '','10^{2}', '', '10^{3}', '', '10^{4}'})
    yticks([0, 0.5, 1])

    xlabel('signal-to-noise ratio','Interpreter','latex')
    ylabel('ratio', 'Interpreter','latex')
    
    title_strg = 'b) Relative \# support vectors';
    title(title_strg, 'Interpreter','latex')
    set(gca,'fontsize',axes_font_size)

    % set fontype
    set(findall(gcf,'-property','FontName'),'FontName',options.plotStyle.fontname)
end

function [A_trim, B_trim] = remove_outliers(A, B)
    
    % initialize outputs
    A_trim = A;
    B_trim = B;
    
    % find locations of outliers in rows of A and in B
    idx_outliers_A = isoutlier(A, 'percentiles', [10, 90], 2);
    idx_outliers_B = isoutlier(B, 'percentiles', [10, 90], 2);
    
    % combine locations into single index matrix
    idx_outliers_AB = idx_outliers_A | idx_outliers_B;
    
    % remove all outlier runs in A and B
    A_trim(idx_outliers_AB) = nan;
    B_trim(idx_outliers_AB) = nan;

end