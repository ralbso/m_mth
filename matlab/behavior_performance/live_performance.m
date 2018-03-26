function live_performance(live_data, short_ax, long_ax)
% LIVE_PERFORMANCE Quick glance at behavior during session.
%   Function takes data being generated, and the handles for each plot.
%   Massive overhaul of performance.m
%   Returns session performance plots in real time.
%   See also GETLATESTFILE, VLINE, PERFORMANCE.

position = live_data(:,1);
last_position = live_data(:,2);
vr_world = live_data(:,3);
last_world = live_data(:,4);
valve_status = live_data(:,5);
trial_number = live_data(:,6);
lick = live_data(:,7);

default = false(length(live_data));
triggered = false(length(live_data));
licked = false(length(live_data));

for i = 1:length(live_data)
    
    if lick(i) == 1
        licked(i) = true;
    end

    if valve_status(i) ~= 0
        licked(i) = false;
        vr_world(i) = last_world(i);
        if valve_status(i) == 2
            default(i) = true;
            position(i) = last_position(i);
        elseif valve_status(i) == 1
            triggered(i) = true;
        end
    end
end

if vr_world(1) == 3
    axes(short_ax)
    line('XData',[position(triggered),position(triggered)],'YData',[trial_number(triggered)-1,trial_number(triggered)-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    line('XData',[position(default),position(default)],'YData',[trial_number(default)-1,trial_number(default)-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    line('XData',[position(licked),position(licked)],'YData',[trial_number(licked),trial_number(licked)], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b'); 
end

if vr_world(1) == 4
    axes(long_ax)
    line('XData',[position(triggered),position(triggered)],'YData',[trial_number(triggered)-1,trial_number(triggered)-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    line('XData',[position(default),position(default)],'YData',[trial_number(default)-1,trial_number(default)-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    line('XData',[position(licked),position(licked)],'YData',[trial_number(licked),trial_number(licked)], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b');
end

end
