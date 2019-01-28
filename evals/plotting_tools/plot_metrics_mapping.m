%rescale_factor = 1;
rescale_factor = 0.8;
text_size = 10.5;
plot_aspect_ratio = [1 2 1];

do_plot = 1;
show_legend = 0;
percentile = 0.99;

trials = fieldnames(logger);
methods = fieldnames(logger.trial1);

% Choose which methods to plot.
% NB: - Always include "1" (trial number).
methods_select = [1,3,5,7];
methods = {methods{methods_select}};

% Last trial is incomplete.
if (length(methods) ~= length(fieldnames(logger.(trials{end}))))
    trials = trials(1:end-1);
end
disp(['Number of trials = ', num2str(length(trials))])

time_vector = 0:0.1:150;

P_traces = zeros(length(methods)-1,length(time_vector));
rmses = zeros(length(methods)-1,length(time_vector));
mlls = zeros(length(methods)-1,length(time_vector));
Rob_Ps_Aopt = zeros(length(methods)-1,length(time_vector));
Rob_Ps_Dopt = zeros(length(methods)-1,length(time_vector));
pose_rmses = zeros(length(methods)-1,length(time_vector));

for i = 1:length(trials)
    
    for j = 2:length(methods)
        
        try
            time = logger.(trials{i}).(methods{j}).times;
        catch
            disp(['Cant find ', trials{i}, ' ' methods{j}])
            break;
        end
        
        P_trace = logger.(trials{i}).(methods{j}).P_traces;
        rmse = logger.(trials{i}).(methods{j}).rmses;
        mll = logger.(trials{i}).(methods{j}).mlls;
        
        Rob_P_Aopt = [];
        Rob_P_Dopt = [];
        
        for k = 1:size(metrics.times,1)
            Rob_P_Aopt = [Rob_P_Aopt; trace(logger.(trials{i}).(methods{j}).Rob_Ps(:,:,k))];
            Rob_P_Dopt = [Rob_P_Dopt; det(logger.(trials{i}).(methods{j}).Rob_Ps(:,:,k))];
        end
        
        pose_rmse = sqrt(sum((logger.(trials{i}).(methods{j}).points_meas - ...
            logger.(trials{i}).(methods{j}).points_meas_gt).^2, 2)/3);
        
        ts = timeseries(P_trace, time);
        ts_resampled = resample(ts, time_vector, 'zoh');
        P_traces(j-1,:,i) = ts_resampled.data';
        
        ts = timeseries(rmse, time);
        ts_resampled = resample(ts, time_vector, 'zoh');
        rmses(j-1,:,i) = ts_resampled.data';
        
        ts = timeseries(mll, time);
        ts_resampled = resample(ts, time_vector, 'zoh');
        mlls(j-1,:,i) = ts_resampled.data';
        
        ts = timeseries(Rob_P_Aopt, time);
        ts_resampled = resample(ts, time_vector, 'zoh');
        Rob_Ps_Aopt(j-1,:,i) = ts_resampled.data';
        
        ts = timeseries(Rob_P_Dopt, time);
        ts_resampled = resample(ts, time_vector, 'zoh');
        Rob_Ps_Dopt(j-1,:,i) = ts_resampled.data';

        ts = timeseries(pose_rmse, time);
        ts_resampled = resample(ts, time_vector, 'zoh');
        pose_rmses(j-1,:,i) = ts_resampled.data';

    end
    
end

% Find means and medians.
mean_P_traces = sum(P_traces,3)./length(trials);
mean_rmses = sum(rmses,3)./length(trials);
mean_mlls = sum(mlls,3)./length(trials);
mean_Rob_Ps_Aopt = sum(Rob_Ps_Aopt,3)./length(trials);
mean_Rob_Ps_Dopt = sum(Rob_Ps_Dopt,3)./length(trials);
mean_pose_rmses = sum(pose_rmses,3)./length(trials);
median_P_traces = median(P_traces,3);
median_rmses = median(rmses,3);
median_mlls = median(mlls,3);
median_pose_rmses = median(pose_rmses,3);

% Find confidence intervals
% http://ch.mathworks.com/matlabcentral/answers/159417-how-to-calculate-the-confidence-interva
SEM_P_traces = [];
SEM_rmses = [];
SEM_mlls = [];
SEM_Rob_Ps_Aopt = [];
SEM_Rob_Ps_Dopt = [];
SEM_pose_rmses = [];

for j = 2:length(methods)
    
    SEM_P_traces(j-1,:) = std(squeeze(P_traces(j-1,:,:))', 'omitnan')/...
        sqrt(length(trials));
    SEM_rmses(j-1,:) = (std(squeeze(rmses(j-1,:,:))', 'omitnan')/...
        sqrt(length(trials)));
    SEM_mlls(j-1,:) = (std(squeeze(mlls(j-1,:,:))', 'omitnan')/...
        sqrt(length(trials)));
    SEM_Rob_Ps_Aopt(j-1,:) = (std(squeeze(Rob_Ps_Aopt(j-1,:,:))', 'omitnan')/...
        sqrt(length(trials)));
    SEM_Rob_Ps_Dopt(j-1,:) = (std(squeeze(Rob_Ps_Dopt(j-1,:,:))', 'omitnan')/...
        sqrt(length(trials)));
    SEM_pose_rmses(j-1,:) = (std(squeeze(pose_rmses(j-1,:,:))', 'omitnan')/...
        sqrt(length(trials)));    
end

% Symmetric
ts = tinv(percentile, length(trials));

colours = [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880];
%0.6350    0.0780    0.1840;
%0.3010    0.7450    0.9330;
%0.1379    0.1379    0.0345];
transparency = 0.3;


%% PLOTTING %%

if (do_plot)
    
    figure;
    
    %% RMSE %%
    subplot(1,3,1)
    hold on
    if length(methods)-1 == 4
        boundedline(time_vector, mean_rmses(1,:), SEM_rmses(1,:)*ts, ...
            time_vector, mean_rmses(2,:), SEM_rmses(2,:)*ts, ...
            time_vector, mean_rmses(3,:), SEM_rmses(3,:)*ts, ...
            time_vector, mean_rmses(4,:), SEM_rmses(4,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    elseif length(methods)-1 == 3
        boundedline(time_vector, mean_rmses(1,:), SEM_rmses(1,:)*ts, ...
            time_vector, mean_rmses(2,:), SEM_rmses(2,:)*ts, ...
            time_vector, mean_rmses(3,:), SEM_rmses(3,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    elseif length(methods)-1 == 2
        boundedline(time_vector, mean_rmses(1,:), SEM_rmses(1,:)*ts, ...
            time_vector, mean_rmses(2,:), SEM_rmses(2,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    end
    
    for i = 1:length(methods)-1
        rmse = mean_rmses(i,:);
        h(i) = plot(time_vector, rmse, 'LineWidth', 1, 'Color', colours(i,:));
    end
    
    h_xlabel = xlabel('Time (s)');
    h_ylabel = ylabel('Map RMSE');
    set([h_xlabel, h_ylabel], ...
        'FontName'   , 'Helvetica');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'YTick'       , 0:2:12, ...
        'LineWidth'   , 1         , ...
        'FontSize'    , text_size, ...
        'LooseInset', max(get(gca,'TightInset'), 0.02));
    rescale_axes(rescale_factor);
    axis([0 time_vector(end) 1 10])
    pbaspect(gca, plot_aspect_ratio)
    hold off
    
    %% Robot covariance trace (A-opt) %%
    subplot(1,3,2)
    hold on
    if length(methods)-1 == 4
        boundedline(time_vector, mean_Rob_Ps_Aopt(1,:), SEM_Rob_Ps_Aopt(1,:)*ts, ...
            time_vector, mean_Rob_Ps_Aopt(2,:), SEM_Rob_Ps_Aopt(2,:)*ts, ...
            time_vector, mean_Rob_Ps_Aopt(3,:), SEM_Rob_Ps_Aopt(3,:)*ts, ...
            time_vector, mean_Rob_Ps_Aopt(4,:), SEM_Rob_Ps_Aopt(4,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    elseif length(methods)-1 == 3
        boundedline(time_vector, mean_Rob_Ps_Aopt(1,:), SEM_Rob_Ps_Aopt(1,:)*ts, ...
            time_vector, mean_Rob_Ps_Aopt(2,:), SEM_Rob_Ps_Aopt(2,:)*ts, ...
            time_vector, mean_Rob_Ps_Aopt(3,:), SEM_Rob_Ps_Aopt(3,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    elseif length(methods)-1 == 2
        boundedline(time_vector, mean_Rob_Ps_Aopt(1,:), SEM_Rob_Ps_Aopt(1,:)*ts, ...
            time_vector, mean_Rob_Ps_Aopt(2,:), SEM_Rob_Ps_Aopt(2,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    end
    
    for i = 1:length(methods)-1
        Rob_P_Aopt = mean_Rob_Ps_Aopt(i,:);
        h(i) = plot(time_vector, Rob_P_Aopt, 'LineWidth', 1, 'Color', colours(i,:));
    end
    
    h_xlabel = xlabel('Time (s)');
    h_ylabel = ylabel('Tr(\Sigma)');
    set([h_xlabel, h_ylabel], ...
        'FontName'   , 'Helvetica');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'YTick'       , 0:0.005:1, ...
        'LineWidth'   , 1         , ...
        'FontSize'    , text_size, ...
        'LooseInset', max(get(gca,'TightInset'), 0.02));
    rescale_axes(rescale_factor);
    axis([0 time_vector(end) 0 0.02])
    pbaspect(gca, plot_aspect_ratio)
    hold off
 
    %% Robot pose RMSE %%
    subplot(1,3,3)
    hold on
    if length(methods)-1 == 4
        boundedline(time_vector, mean_pose_rmses(1,:), SEM_pose_rmses(1,:)*ts, ...
            time_vector, mean_pose_rmses(2,:), SEM_pose_rmses(2,:)*ts, ...
            time_vector, mean_pose_rmses(3,:), SEM_pose_rmses(3,:)*ts, ...
            time_vector, mean_pose_rmses(4,:), SEM_pose_rmses(4,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency); 
    elseif length(methods)-1 == 3
        boundedline(time_vector, mean_pose_rmses(1,:), SEM_pose_rmses(1,:)*ts, ...
            time_vector, mean_pose_rmses(2,:), SEM_pose_rmses(2,:)*ts, ...
            time_vector, mean_pose_rmses(3,:), SEM_pose_rmses(3,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    elseif length(methods)-1 == 2
        boundedline(time_vector, mean_pose_rmses(1,:), SEM_pose_rmses(1,:)*ts, ...
            time_vector, mean_pose_rmses(2,:), SEM_pose_rmses(2,:)*ts, ...
            'alpha', 'cmap', colours, 'transparency', transparency);
    end
    
    for i = 1:length(methods)-1
        pose_rmse = mean_pose_rmses(i,:);
        h(i) = plot(time_vector, pose_rmse, 'LineWidth', 1, 'Color', colours(i,:));
    end
    
    h_xlabel = xlabel('Time (s)');
    h_ylabel = ylabel('Robot pose RMSE (m)');
    set([h_xlabel, h_ylabel], ...
        'FontName'   , 'Helvetica');
    set(gca, ...
        'Box'         , 'off'     , ...
        'TickDir'     , 'out'     , ...
        'TickLength'  , [.02 .02] , ...
        'XMinorTick'  , 'on'      , ...
        'YMinorTick'  , 'on'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'YTick'       , 0:0.025:0.2, ...
        'LineWidth'   , 1         , ...
        'FontSize'    , text_size, ...
        'LooseInset', max(get(gca,'TightInset'), 0.02));
    rescale_axes(rescale_factor);
    axis([0 time_vector(end) 0 0.1])
    pbaspect(gca, plot_aspect_ratio)
    hold off

    set(gcf, 'Position', [86, 540, 728, 434])
    set(gcf,'color','w')
    set(findall(gcf,'-property','FontName'),'FontName','Times')
    
    if (show_legend)
        h_legend = legend(h, 'Unc.', 'Unc. rate', 'Renyi', 'Random');
        %set(h_legend, 'Location', 'SouthOutside');
        %set(h_legend, 'orientation', 'horizontal')
        %set(h_legend, 'box', 'off')
    end
    
end

function [] = rescale_axes(scalefactor)

g = get(gca,'Position');
g(1:2) = g(1:2) + (1-scalefactor)/2*g(3:4);
g(3:4) = scalefactor*g(3:4);
set(gca,'Position',g);

end

%close all;