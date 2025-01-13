% DESCRIPTION: The purpose of this script is to construct an example of
% timeseries obtained from the batch_reactor model from two classes used in
% experiment 2.

%% select model
clear; clc; close all;                               % clear workspace
rng(1)                                               % set random number generator seed for reproducibility
sysUID = dynamical_system('batch_reactor', 'UID');   % select example model and identifiability status

% load data from experiment 2
load('Results/pExperiment2_batch_reactor_202411120208.mat')

noise_level = 4;
data = resultsUID.data.noiseLevel(noise_level).mleDataTest.observations;

%% set plot styles and plot
close all

figuresize = [6 6 9 5];

fontname = 'Sans Serif';
axes_font_size = 8;
legend_font_size = 8;
labelSize = 8;

linestyle_C0 = '-';
linestyle_C1 = '-';
marker_C0 = '*';
marker_C1 = 'o';
linestyle_width = 0.8;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];

x_limits = [0 12];
y_limits = [-5 25];

% ----- Plot -----

% set number of timeseries per class to be plotted
num_ts_plot = 10;

% extract labels and find class memberships
labels = [data.label];
idx_C0 = find(labels == 0);
idx_C1 = find(labels == 1);

fig = figure(1);
clf(fig);
set(fig, 'units', 'centimeters', 'color', 'white', 'position', figuresize, 'PaperPositionMode', 'auto');

hold on
for i = 1:num_ts_plot
    plot(data(idx_C0(i)).timeseries(1, :), data(idx_C0(i)).timeseries(2, :), Color=blue, LineStyle=linestyle_C0, LineWidth=linestyle_width, Marker=marker_C0)
    plot(data(idx_C1(i)).timeseries(1, :), data(idx_C1(i)).timeseries(2, :), Color=orange, LineStyle=linestyle_C1, LineWidth=linestyle_width, Marker=marker_C1)
end

xlim(x_limits)
ylim(y_limits)

xlabel('t', 'Interpreter','latex')
ylabel('x(t)', 'Interpreter','latex')
legend('class 0', 'class 1', 'Location','northwest','Interpreter','latex');

set(gca, 'fontsize', axes_font_size)
set( findall(gcf, '-property', 'FontName'), 'FontName', fontname)

%% set options for printing the PDF
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', figuresize(3:4));
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 figuresize(3:4)]);
set(gcf, 'renderer', 'painters');

print(gcf, '-dpdf', 'Figures/BR_example_ts.pdf');