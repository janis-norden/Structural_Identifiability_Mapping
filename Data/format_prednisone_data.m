clear; clc; close all

% load data
load('pred_data.mat')

% 
ID = [7, 8, 1, 2, 9, 10, 3, 4, 11, 12, 5, 6];

% create vector of labels (0 -> slow absorbers, 1 -> medium absorbers, 0 -> fast absorbers)
labels = [2, 2, 1, 2, 2, 1, 1, 0, 2, 1, 0, 1];


%% Plot data
close all

% define class colours
colours = {'red', 'blue', 'magenta'};

% create plot
figure
hold on
for n = [2, 3, 4, 5, 6, 7, 8, 9, 10]
    plot(ts, P(:, n), Color = colours{labels(n) + 1}, Marker='*', LineStyle='--');
    plot(ts, L(:, n), Color = colours{labels(n) + 1}, Marker='*', LineStyle='-');
end

handle_slow = plot(ts, P(:, 11), Color = colours{labels(11) + 1}, Marker='*', LineStyle='--');
plot(ts, L(:, 11), Color = colours{labels(11) + 1}, Marker='*', LineStyle='-');

handle_medium = plot(ts, P(:, 12), Color = colours{labels(12) + 1}, Marker='*', LineStyle='--');
plot(ts, L(:, 12), Color = colours{labels(12) + 1}, Marker='*', LineStyle='-');

handle_fast = plot(ts, P(:, 1), Color = colours{labels(1) + 1}, Marker='*', LineStyle='--');
plot(ts, L(:, 1), Color = colours{labels(1) + 1}, Marker='*', LineStyle='-');

legend([handle_slow, handle_medium, handle_fast], 'Slow absorbers', 'Medium absorbers', 'Fast absorbers')

xlabel('t (min)')
ylabel('y(t)')


%% save data
save('pred_data.mat', 'P', 'L', 'ts', 'labels')