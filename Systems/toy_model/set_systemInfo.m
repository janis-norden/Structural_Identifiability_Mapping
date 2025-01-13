clear; clc; close all

numStateVars = 1;

obsIdx = 1;

ROI = [0,  3;     % range for a
       0,  3;     % range for b
       ];

%% save obsIDx and ROI
save('systemInfo.mat', 'numStateVars', 'obsIdx', 'ROI')