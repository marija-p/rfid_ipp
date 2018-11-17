num_trials = 3;

% UAV workspace dimensions [m]
dim_x_env = 12;
dim_y_env = 12;
dim_z_env = 5;

[map_params, planning_params, opt_params, gp_params, ...
    training_data, gt_data, testing_data] = ...
    load_params_and_data(dim_x_env, dim_y_env, dim_z_env);

logger = [];

for t = 1:num_trials
    
    planning_params.meas_freq = 0.1;
    
    rng(t, 'twister');
    logger.(['trial', num2str(t)]).num = t;
    
    planning_params.modified_kernel = 0;
    [metrics] = slam_gp(map_params, planning_params, opt_params, gp_params, ...
        training_data, gt_data, testing_data);
    logger.(['trial', num2str(t)]).('no_UI') = metrics;
    clear global
    
    planning_params.modified_kernel = 1;
    [metrics] = slam_gp(map_params, planning_params, opt_params, gp_params, ...
        training_data, gt_data, testing_data);
    logger.(['trial', num2str(t)]).('UI') = metrics; 
    clear global
    
end