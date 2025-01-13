clear; clc; close all

numStateVars = 2;

obsIdx = 1;

ROI = [   0,  10;     % range for b1
          0,  50;     % range for b2
       0.01,   1;     % range for mu
       0.01,   5;     % range for Ks
       0.01,   1;     % range for Y
       0.01,   1      % range for Kd
       ];

%% save obsIDx and ROI
save('systemInfo.mat', 'numStateVars', 'obsIdx', 'ROI')