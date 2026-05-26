function fig = plotOutcomesExperiment3(resultsUID, options)

    % Extract plot styles
    linestyle_UID = options.plotStyle.linestyle_UID;
    linestyle_UID_SIM = options.plotStyle.linestyle_UID_SIM;
    linestyle_MLP = options.plotStyle.linestyle_MLP;
    linestyle_width = options.plotStyle.linestyle_width;
    axes_font_size = options.plotStyle.axes_font_size;
    
    % Unpack generalization errors
    genError_SVM = resultsUID.outcomes.SVM.gen_error;
    genError_SVM_SIM = resultsUID.outcomes.SVM_SIM.gen_error;

    % remove outlier runs
    genError_SVM_trim = remove_outliers(genError_SVM);
    genError_SVM_SIM_trim = remove_outliers(genError_SVM_SIM);

    % Extract experiment info
    numTrExVec = resultsUID.experimentPars.numTrExVec;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    blue = [0 0.4470 0.7410];
    orange = [0.8500 0.3250 0.0980];
    grey = 0.6 * [1, 1, 1];

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

    errorbar(numTrExVec, mean(genError_SVM_trim(:, :, 1), 2, 'omitnan'), std(genError_SVM_trim(:, :, 1), 0, 2, 'omitnan'), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_SVM_SIM_trim(:, :, 1), 2, 'omitnan'), std(genError_SVM_SIM_trim(:, :, 1), 0, 2, 'omitnan'), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)

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

    errorbar(numTrExVec, mean(genError_SVM_trim(:, :, 2), 2, 'omitnan'), std(genError_SVM_trim(:, :, 2), 0, 2, 'omitnan'), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_SVM_SIM_trim(:, :, 2), 2, 'omitnan'), std(genError_SVM_SIM_trim(:, :, 2), 0, 2, 'omitnan'), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)


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
    
    errorbar(numTrExVec, mean(genError_SVM_trim(:, :, 3), 2, 'omitnan'), std(genError_SVM_trim(:, :, 3), 0, 2, 'omitnan'), Color=orange, LineStyle=linestyle_UID, LineWidth=linestyle_width)
    errorbar(numTrExVec, mean(genError_SVM_SIM_trim(:, :, 3), 2, 'omitnan'), std(genError_SVM_SIM_trim(:, :, 3), 0, 2, 'omitnan'), Color=blue, LineStyle=linestyle_UID_SIM, LineWidth=linestyle_width)


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



function A_trim = remove_outliers(A)

    % initialize output array
    A_trim = A;

    % extract number of columns of A
    [n_train_vals, ~, n_grids] = size(A);
    
    % loop over grids
    for k = 1:n_grids
        
        % loop over values of training examples
        for i = 1:n_train_vals
            
            % find locations of outliers
            idx_outliers = isoutlier(A(i, :, k), 'percentiles', [10, 90]);
            
            % set outlier values to Nan
            A_trim(i, idx_outliers, k) = nan;

        end

    end

end




