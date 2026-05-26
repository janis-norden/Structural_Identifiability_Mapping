clear; clc; close all

%% print summary table for experiment 1

% select filenames for experiment 1
clear('filenames_results')
filenames_results.CCM2 = 'prExperiment1_CCM2_202506281327';
filenames_results.CCM4 = 'prExperiment1_CCM4_202506281947';
filenames_results.CML = 'prExperiment1_CML_202506290218';
filenames_results.BR = 'prExperiment1_batch_reactor_202506280844';

% set formatting options
options.formatSpec = '%.4f';

% print summary table
printSummaryTableExperiment1(filenames_results, options);

%% print summary table for experiment 2

% select filenames for experiment 2
clear('filenames_results')
filenames_results.toy_model = 'prExperiment2_toy_model_202507032219';
filenames_results.CCM2 = 'prExperiment2_CCM2_202507031950';
filenames_results.CCM4 = 'prExperiment2_CCM4_202507032038';
filenames_results.CML = 'prExperiment2_CML_202507032204';
filenames_results.BR = 'prExperiment2_batch_reactor_202507031932';

% set formatting options
options.formatSpec = '%.2f';

% print summary table
printSummaryTableExperiment2(filenames_results, options);

%% print summary table for experiment 3

% select filenames for experiment 3
clear('filenames_results')
filenames_results.toy_model = 'prExperiment3_toy_model_202508060733';
filenames_results.CCM2 = 'prExperiment3_CCM2_202508051956';
filenames_results.CCM4 = 'prExperiment3_CCM4_202508060048';
filenames_results.CML = 'prExperiment3_CML_202508060544';
filenames_results.BR = 'prExperiment3_batch_reactor_202507291952';

% set formatting options
options.formatSpec = '%.2f';

% print summary table
printSummaryTableExperiment3(filenames_results, options);