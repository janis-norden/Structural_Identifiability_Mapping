clear; clc; close all

numStateVars = 3;

obsIdx = 2;

ROI = [0,  0.1;     % range for k01
       0,  0.1;     % range for k02
       0,  0.1;     % range for k12
       0,  0.1;     % range for k21
       ];

%% save obsIDx and ROI
save('systemInfo.mat', 'numStateVars', 'obsIdx', 'ROI')