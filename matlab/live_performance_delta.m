function live_performance_beta(position, vr_world, last_world, valve_status, trial_number, lick, short_ax, long_ax)
% LIVE_PERFORMANCE Quick glance at behavior during session.
%   Function takes data being generated, and the handles for each plot.
%   Massive overhaul of performance.m
%   Returns session performance plots in real time.
%   See also GETLATESTFILE, VLINE, PERFORMANCE.

fprintf('func1 : %d \n', valve_status);

triggered = false;
default = false;
licked = false;

if vr_world == 3 || last_world == 3
    
    if lick == 1
        licked = true;
    end
    
    fprintf('func2 : %d \n', valve_status);

    if valve_status == 2
        triggered = true;
        licked = false;
    elseif valve_status == 1
        default = true;
        licked = false;
    end
    
    fprintf('func3 : %d \n', valve_status);

    if triggered
        axes(short_ax)
        line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    elseif default
        axes(short_ax)
        line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    elseif licked
        axes(short_ax)
        line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b'); 
    end
        
elseif vr_world == 4 || last_world == 4
    
    if valve_status == 2
        triggered = true;
        licked = false;
    elseif valve_status == 1
        default = true;
        licked = false;
    end
    
    if lick == 1
        licked = true;
    end

    if triggered
        axes(long_ax)
        line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    elseif default 
        axes(long_ax)
        line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    elseif licked
        axes(long_ax)
    	line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b');
    end
end
end
