function live_performance(live_data, short_ax, long_ax)
% LIVE_PERFORMANCE Quick glance at behavior during session.
%   Function takes data being generated, and the handles for each plot.
%   Massive overhaul of performance.m
%   Returns session performance plots in real time.
%   See also GETLATESTFILE, VLINE, PERFORMANCE.

default = false(length(live_data));
triggered = false(length(live_data));
licked = false(length(live_data));


if ~isempty(live_data)
    position = live_data(:,1);
    last_position = live_data(:,2);
    vr_world = live_data(:,3);
    last_world = live_data(:,4);
    valve_status = live_data(:,5);
    trial_number = live_data(:,6);
    lick = live_data(:,7);
end

for i = 1:length(live_data)
    if vr_world(i) == 5 && (last_world(i) == 3 || last_world(i) == 4)
        
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

        if vr_world(i) == 3
            if triggered(i)
                axes(short_ax)
                line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
            elseif default(i)
                axes(short_ax)
                line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
            elseif licked(i)
                axes(short_ax)
                line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b'); 
            end
        end

        if vr_world(i) == 4
            if triggered(i)
                axes(long_ax)
                line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'g');
            elseif default(i) 
                axes(long_ax)
                line('XData',[position,position],'YData',[trial_number-1,trial_number-1], 'LineStyle', 'none', 'Marker', '*', 'MarkerEdgeColor', 'r');
            elseif licked(i)
                axes(long_ax)
                line('XData',[position,position],'YData',[trial_number,trial_number], 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b');
            end
        end
    end
end
end
