% DESCRIPTION: The purpose of this script is to run the indicated 
% experiment scripts one after the other. The user may specify a time delay 
% with which the expirments are run by setting numMinutes to the desired
% number of minutes. Which experiments are run and in which order can be
% adjusted in the sectioins below. Per default, this script only runs
% experiment 1 for the batch_reactor model.

% set delay for start of experiment
numMinutes = 0;

% turn off warnings temporarily
warning('off', 'all')

% display starting message
disp('Experiment started')
disp(['Delay: ', num2str(numMinutes), ' minutes'])
pause(numMinutes * 60)

% get time at start of experiment
start_date = char(datetime('now', 'Format', 'y-d-MM_HH-mm-ss'));
save('start_date.mat', 'start_date')

% turn off analysis mode
analysis_mode = false;
save('analysis_mode.mat', 'analysis_mode')

%%%%%%%%%%%%%%%%%%%%%%%%%%   EXPERIMENT 1   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Experiment1_batch_reactor

% Experiment1_CCM2
% 
% Experiment1_CCM4
% 
% Experiment1_CML

%%%%%%%%%%%%%%%%%%%%%%%%%%%   EXPERIMENT 2   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Experiment2_batch_reactor
% 
% Experiment2_CCM2
% 
% Experiment2_CCM4
% 
% Experiment2_CML
% 
% Experiment2_toy_model


%%%%%%%%%%%%%%%%%%%%%%%%%%%   EXPERIMENT 3   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Experiment3_batch_reactor
% 
% Experiment3_CCM2
% 
% Experiment3_CCM4
% 
% Experiment3_CML
% 
% Experiment3_toy_model


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Experiment ended')

% get time at end of experiment
load('start_date.mat')
end_date = char(datetime('now', 'Format', 'y-d-MM_HH-mm-ss'));

disp(['Start time:  ' , start_date])
disp(['End time:    ' , end_date])

% delete temporary save file
delete('start_date.mat')

% turn on analysis mode again
analysis_mode = true;
save('analysis_mode.mat', 'analysis_mode')

% turn warnings on again
warning('on', 'all')