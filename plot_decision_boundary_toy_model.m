% DESCRIPTION: The purpose of this script is to visualize the basic idea
% behind the Structural Identifiability Mapping (SIM). To this end, data is
% generated for a binary classification task on the toy_model and the
% resulting example data is plotted both in the space of the original model
% parameters as well as the space of structurally identifiable
% combinations. The resulting demonstrates how SIM can simplify a
% classification task.


%% Clear workspace and load dynamical system
clear; clc; close all;                               % clear workspace
rng(1)                                               % set random number generator seed for reproducibility
sysUID = dynamical_system('toy_model', 'UID');       % select example model and identifiability status
%% Generate labled sets of timeseries

numTrainExamples = 100;
t = 0:0.01:1;
sigmaObs = 0.2;
% ---------------- CLASSIFICATION PROBLEM -------------------------------->
% Set parameter values associated with class 0 and class 1
parClass.C0.mu = [1, 1];
parClass.C1.mu = 0.8 * [1, 1];

% set covariance matrix for intra-class variation
parClass.C0.Sigma = diag([10^-4, 10^-4]);
parClass.C1.Sigma = diag([10^-4, 10^-4]);
% ------------------------------------------------------------------------<

tsData = sysUID.genBinLabelTSGrid(numTrainExamples, parClass, t, sigmaObs);
%% Conversion to labeled MLE data
mleData = sysUID.tsData2mleData(tsData);
mleMat = [mleData.observations.MLE_theta]';
mleMatPhi = [mleData.observations.MLE_Phi]';

%% Plots
clc; close all

figuresize = [6 6 9 5];
fontname = 'Sans Serif';

markerSize = 5;
markerWidth = 0.5;
lineWidth = 1;
labelSize = 8;
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];

% Find instances of each class for plotting
idx0 = find([tsData.observations.label] == 0);
idx1 = find([tsData.observations.label] == 1);

% decision boundary (a,b)
slope = -0.18;
offset = 0.8;
xDecTheta = 0:0.01:3;
yDecTheta = slope*xDecTheta + offset;

% decision boundary in Phi
xDecPhi = -1:0.01:1;
yDecPhi = 0.78 * ones(1, length(xDecPhi));

% Plots
fig = figure(1);
clf(fig);
set(fig,'units','centimeters','color','white','position',figuresize,'PaperPositionMode','auto');
tiledlayout(1, 9, 'TileSpacing', 'compact', 'Padding', 'none')

nexttile(1, [1, 7])
hold on
plot(mleMat(idx0, 1), mleMat(idx0, 2), '*', 'Color', blue, 'MarkerSize', markerSize, 'LineWidth', markerWidth)
plot(mleMat(idx1, 1), mleMat(idx1, 2), '*', 'Color', orange,'MarkerSize', markerSize, 'LineWidth', markerWidth)
plot(xDecTheta, yDecTheta, 'k', 'LineWidth', lineWidth)
xlim([sysUID.ROI(1, 1), sysUID.ROI(1, 2)])
ylim([sysUID.ROI(2, 1), sysUID.ROI(2, 2)])
xlabel('a', 'Interpreter','latex')
ylabel('b', 'Interpreter','latex')
title('\textbf{a)}', 'Interpreter','latex')
legend('Data class 0', 'Data class 1', 'Decision boundary', 'Interpreter','latex')
set(gca,'fontsize',labelSize)

nexttile([1, 2])
hold on
plot(zeros(length(idx0)), mleMatPhi(idx0), '*', 'Color', blue, 'MarkerSize', markerSize, 'LineWidth', markerWidth)
plot(zeros(length(idx1)), mleMatPhi(idx1), '*', 'Color', orange, 'MarkerSize', markerSize, 'LineWidth', markerWidth)
plot(xDecPhi, yDecPhi, 'k', 'LineWidth', lineWidth)
%xlabel('$/phi$', 'Interpreter','latex')
xlim([-1, 1]);
ylim([0.45, 1.25])
ylabel('$\Phi$', 'Interpreter','latex')
title('\textbf{b)}', 'Interpreter','latex')
set(gca,'XColor', 'none','fontsize',labelSize)

% set fontype
set(findall(gcf,'-property','FontName'),'FontName',fontname)

%% Save PDF to Figures folder

% set options for printing the PDF
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', figuresize(3:4));
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 figuresize(3:4)]);
set(gcf, 'renderer', 'painters');

print(gcf, '-dpdf', 'Figures/decision_boundary_toy_model.pdf');