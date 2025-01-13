% DESCRIPTION: The purpose of this script is to create the experiment
% summary tables included in the paper. The sections below may be used to
% create summary tables for experiments 1, 2, and 3, respectively. The user
% needs to specify which set of results should be used for the creation of
% the tables.

clear; clc; close all
%% print summary table for experiment 1

% select filenames for experiment 1
clear('filenames_results')
filenames_results.CCM2 = 'pExperiment1_CCM2_202411112007';
filenames_results.CCM4 = 'pExperiment1_CCM4_202411112139';
filenames_results.CML = 'pExperiment1_CML_202411120044';
filenames_results.BR = 'pExperiment1_batch_reactor_202411111928';

% set formatting options
options.formatSpec = '%.1g';

% print summary table
printSummaryTableExperiment1(filenames_results, options);

%% print summary table for experiment 2

% select filenames for experiment 2
clear('filenames_results')
filenames_results.toy_model = 'pExperiment2_toy_model_202411120354';
filenames_results.CCM2 = 'pExperiment2_CCM2_202411120219';
filenames_results.CCM4 = 'pExperiment2_CCM4_202411120249';
filenames_results.CML = 'pExperiment2_CML_202411120344';
filenames_results.BR = 'pExperiment2_batch_reactor_202411120208';

% set formatting options
options.formatSpec = '%.2f';

% print summary table
printSummaryTableExperiment2(filenames_results, options);

%% print summary table for experiment 3

% select filenames for experiment 3
clear('filenames_results')
filenames_results.toy_model = 'pExperiment3_toy_model_202411121000';
filenames_results.CCM2 = 'pExperiment3_CCM2_202411120525';
filenames_results.CCM4 = 'pExperiment3_CCM4_202411120719';
filenames_results.CML = 'pExperiment3_CML_202411120925';
filenames_results.BR = 'pExperiment3_batch_reactor_202411120450';

% set formatting options
options.formatSpec = '%.1g';

% print summary table
printSummaryTableExperiment3(filenames_results, options);