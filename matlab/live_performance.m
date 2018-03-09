function live_performance(position, last_position, vr_world, last_world, valve_status, trial_number, lick, short_ax, long_ax)
% LIVE_PERFORMANCE Quick glance at behavior during session.
%   Function takes data being generated, and the handles for each plot.
%   Massive overhaul of performance.m
%   Returns session performance plots in real time.
%   See also GETLATESTFILE, VLINE, PERFORMANCE.

default = false;
triggered = false;
licked = false;

if lick == 1
    licked = true;
end

if valve_status ~= 0
    licked = false;
    vr_world = last_world;
    if valve_status == 2
        default = true;
        position = last_position;
    elseif valve_status == 1
        triggered = true;
    end
end

if vr_world == 3
    if triggered
        axes(short_ax)
        line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    elseif default
        axes(short_ax)
        line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    elseif licked
        axes(short_ax)
        line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b'); 
    end
end
        
if vr_world == 4
    if triggered
        axes(long_ax)
        line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    elseif default 
        axes(long_ax)
        line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    elseif licked
        axes(long_ax)
    	line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b');
    end
end
end
