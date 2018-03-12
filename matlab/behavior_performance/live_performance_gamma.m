function live_performance_gamma(position, vr_world, valve_status, trial_number, lick, ax1, ax2)
% LIVE_PERFORMANCE Quick glance at behavior during session.
%   Function takes data being generated, and the handles for each plot.
%   Massive overhaul of performance.m
%   Returns session performance plots in real time.
%   See also GETLATESTFILE, VLINE, PERFORMANCE.

triggered = false;
default = false;
licked = true;

% Short track

if vr_world == 3

    if lick == 1 && valve_status == 2
        triggered = true;
        licked = false;
    elseif valve_status == 1
        default = true;
        licked = false;
    end
 
%     if triggered
%         position_triggered = position;
%         trial_triggered = trial_number;
%         licked = false;
%     elseif default
%         position_default = position;
%         trial_default = trial_number;
%         licked = false;
%     end
    
    if triggered
        line(ax1, position, trial_number, 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    elseif default   
        line(ax1, position, trial_number, 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    elseif licked
       line(ax1, lick, trial_number, 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b'); 
    end
    
% Long tracks
    
elseif vr_world == 4

    if lick == 1 && valve_status == 2
        triggered = true;
        licked = false;
    elseif valve_status == 1
        default = true;
        licked = false;
    end
    
%     if triggered
%         position_triggered = position;
%         trial_triggered = trial_number;
%         licked = false;
%     else
%         position_default = position;
%         trial_default = trial_number;
%         licked = false;
%     end

    if triggered
        line(ax2, position_triggered, trial_triggered, 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
    elseif default   
        line(ax2, position_default, trial_default, 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
    elseif licked
    	line(ax2, lick, trial_number, 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b');
    end
end
end
