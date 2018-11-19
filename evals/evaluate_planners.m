%clear all; close all; clc;

% If data already exists, want to append to it for the trials it contains.
append_to_logger = 1;

% Number of trials to run
if (~append_to_logger)
    num_trials = 5;
else
    trials = fieldnames(logger);
    trials = regexp(trials,'\d*','Match');
    trials = [trials{:}];
    trials_names = [];
    for i = 1:length(trials)
        trials_names = ...
            [trials_names; str2num(cell2mat(trials(i)))];
    end
end

% UAV workspace dimensions [m]
dim_x_env = 12;
dim_y_env = 12;
dim_z_env = 5;

[map_params, planning_params, opt_params, gp_params, ...
    training_data, gt_data, testing_data] = ...
    load_params_and_data(dim_x_env, dim_y_env, dim_z_env);

logger = [];

for i = 1:5
    
    %   planning_params.control_noise_percent = [10, 10, 10];
    
    if (~append_to_logger)
        t = i;
    else
        t = trials_names(i);
    end
    
    logger.(['trial', num2str(t)]).num = t;

%     rng(t, 'twister');
%     gp_params.use_modified_kernel = 0;
%     [metrics] = slam_gp(map_params, planning_params, opt_params, gp_params, ...
%         training_data, gt_data, testing_data);
%     logger.(['trial', num2str(t)]).('no_UI') = metrics;
    clear global
    
    rng(t, 'twister');
    gp_params.use_modified_kernel = 1;
    [metrics] = slam_gp(map_params, planning_params, opt_params, gp_params, ...
        training_data, gt_data, testing_data);
    logger.(['trial', num2str(t)]).('UI') = metrics; 
    clear global
    
    disp(['Completed Trial ', num2str(t)])
    
end