clear; clc; close all

numStateVars = 4;

obsIdx = 2;

ROI = [0,  0.1;     % range for k01
       0,  0.1;     % range for k02
       0,  0.1;     % range for k03 
       0,  0.1;     % range for k04
       0,  0.1;     % range for k12
       0,  0.1;     % range for k23
       0,  0.1;     % range for k34
       0,  0.1;     % range for k21
       0,  0.1;     % range for k32
       0,  0.1;     % range for k43
       ];

%% save obsIDx and ROI
save('systemInfo.mat', 'numStateVars', 'obsIdx', 'ROI')