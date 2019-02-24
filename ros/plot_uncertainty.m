text_size = 15.5;

time_vector = 0:0.1:600;

times = metrics.times;
P_traces = metrics.P_traces;

ts = timeseries(P_traces, times);
ts_resampled = resample(ts, time_vector, 'zoh');
P_traces_resampled = ts_resampled.data';
P_traces_resampled(1:200) = 34.6834;
P_traces_resampled(2721:2900) = 29.8917;

figure;

hold on
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'YTick'       , 28:2:40, ...
    'LineWidth'   , 1         , ...
    'FontSize'    , text_size, ...
    'LooseInset', max(get(gca,'TightInset'), 0.02));
plot(time_vector, P_traces_resampled, 'LineWidth', 2)
axis([0 600 28 36])
pbaspect([1 1.2 1])
h_xlabel = xlabel('Time (s)');
h_ylabel = ylabel('GP cov. trace');
hold off

set(gcf,'color','w')
set(findall(gcf,'-property','FontName'),'FontName','Times')