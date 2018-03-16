function performance_rewrite(bin)
% PERFORMANCE Quick glance at behavior during session.
%   Function takes either 0 or 1 as arg.
%   0 for latest session performance overview; 1 to select a session.
%   Returns session performance overview.
%   See also GETLATESTFILE, VLINE.

%% File selection
% Automatic selection of most recent .csv file in directory
if bin == 0
    file_name = getLatestFile('C:\vr\vroutput\*.csv');
    path = 'C:\vr\vroutput\';
end

% Pop-up box for .csv file selection
if bin == 1
    [file_name, path] = uigetfile('*.csv', 'Select raw data', 'C:\vr\vroutput\');
    if isequal(file_name, 0)
        error('File selection was cancelled.')
    end
end

% Arg can only be 0 or 1
if bin > 1 || bin < 0
    error('Arg can only be 0 or 1.')
end

file_path = fullfile(path, file_name); 

%% Load .csv with session data
data = dlmread(file_path);

% time = data(:,1);             % Time
position = data(:,2);           % Position
% t_frame = data(:,3);          % Time since last frame
velocity = data(:,4);           % Velocity
vr_world = data(:,5);           % Current trial (short, long, blackbox)
valve_status = data(:,6);       % Valve status
num_trials = data(:,7);         % Number of trials
lick = data(:,8);               % Number of licks
% wheel_vel = data(:,9);        % Wheel velocity

%% Your run of the mill setup for quick n' dirty plots

default = false;
triggered = false;
licked = false;

% Get actual trial number
for i = 1:length(num_trials)
    if mod(num_trials(i), 2) ~= 0
        num_trials(i,1) = 1 + floor(num_trials(i,1)/2);
    else
        num_trials(i,1) = floor(num_trials(i,1)/2);
    end
end

% Acknowledge those licks!
if lick == 1
    licked = true;
end

for i = 1:length(data)
    if vr_world == 3
        short_trials = num_trials;
        short_position = 
    end
    if vr_world == 4
        long_trials = num_trials;
    end

if valve_status ~= 0
    licked = false;
    vr_world = vr_world(valve_status ~= 0);
    if valve_status == 2
        default = true;
        position = position(valve_status == 2);
    elseif valve_status == 1
        triggered = true;
    end
end

% set ylim value to change depending on the amount of trials
total_trials = (num_trials(end));
y = total_trials;


%% Average velocity

tempV = zeros(length(vel),1);
thresh = 0.7;               % Slower speed is considered stationary
for t = 1:length(vel)-1
    if vel(t) > thresh
        tempV(t) = vel(t);  % Velocities under thresh will remain as 0
    end
end

vels = tempV(tempV ~= 0);   % Holds velocities over thresholds
avg_vel = sum(vels)/length(vels);

%% First licks

pos_trial_mat_short = [pos_licks_short(pos_licks_short>=200) trial_licks_short(pos_licks_short>=200)];
[~,is,~] = unique(trial_licks_short(pos_licks_short>=200));
first_licks_short = pos_trial_mat_short(is,:);

pos_trial_mat_long = [pos_licks_long(pos_licks_long>=200) trial_licks_long(pos_licks_long>=200)];
[~,il,~] = unique(trial_licks_long(pos_licks_long>=200));
first_licks_long = pos_trial_mat_long(il,:);

if max(first_licks_short(:,1)) ~= 0
    avg_first_lick_short = mean(first_licks_short(:,1));
else
    avg_first_lick_short = 'No licks';
end

if max(first_licks_long(:,1)) ~= 0
    avg_first_lick_long = mean(first_licks_long(:,1));
else
    avg_first_lick_long = 'No licks';
end

%% Alternate plotting
if vr_world == 3
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
% end

%% Figure setup
figure
    
    % Short trials
    subplot(10,5,[2 28])
    short_all = plot(pos_licks_short, trial_licks_short, 'bo')
    
    xlabel('Location (cm)')
    xlim([50 360])
    ylim([0 y])
    ylabel('Trial #') 
    title('Short trials') 
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.432 .445 .036 .48],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone
    vline([320 340], {'k', 'k'})
    annotation('rectangle', [.542 .445 .019 .48],'FaceColor', 'blue','FaceAlpha',.1)
    hold on;
    
    short_trigg = plot(pos_triggered_short, trial_triggered_short, 'g*')
    hold on;
    
    short_def = plot(pos_short_def, trial_short_def, 'r*')
    hold on;
    
    % Long trials
    subplot(10,5,[4 30])
    long_all = plot(pos_licks_long, trial_licks_long, 'bo')
    
    xlabel('Location (cm)')
    xlim([50 420])
    ylim([0 y])
    title('Long trials')
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.734 .445 .0325 .48],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone box
    vline([380 400], {'k', 'k'})
    annotation('rectangle', [.874 .445 .016 .48],'FaceColor','magenta','FaceAlpha',.1)
    hold on;
    
    long_trigg = plot(pos_triggered_long, trial_triggered_long, 'g*')
    hold on;
    
    long_def = plot(pos_long_def, trial_long_def, 'r*')
    hold on;
    
    % First licks
    subplot(10,5,[37 50])
    short_first_lick = plot(first_licks_short(:,1), first_licks_short(:,2), 'bo');
    hold on;
    long_first_lick = plot(first_licks_long(:,1), first_licks_long(:,2), 'ro');
    hold on;
    
    legend('Short track', 'Long track')
    xlabel('Location (cm)')
    xlim([190 420])
    ylim([0 y])
    title('First licks')
    
    vline([200 240], {'k', 'k'})
    annotation('rectangle', [.32 .11 .1052 .227], 'FaceColor','black','FaceAlpha',.1)
    hold on;
    
    vline([320 340], {'k', 'k'})
    annotation('rectangle', [.6393 .11 .0522 .227], 'FaceColor','blue','FaceAlpha',.1)
    hold on;
    
    vline([380 400], {'k', 'k'})
    annotation('rectangle', [.799 .11 .0522 .227], 'FaceColor','magenta','FaceAlpha',.1)
    hold on;
    
    % Adds textbox for session information
    axes('Position', [0.02 0.07 1 1], 'Visible', 'off');
    descr = {'Total trials: ' 
        num2str(total_trials);
        '';
        'Short trials:';
        num2str(total_short_trials);
        '';
        'Long trials:' 
        num2str(total_long_trials);
        '';
        'Average velocity:';
        [num2str(round(avg_vel,2)), ' cm/s'];
        '';
        'Mean first lick (short trials):';
        strcat(num2str(round(avg_first_lick_short,2)), ' cm');
        ''
        'Mean first lick (long trials):'
        strcat(num2str(round(avg_first_lick_long,2)), ' cm')};
    text(0.025,0.4,descr)
    
    % Figure parameters
    x0 = 350;       % x position on screen
    y0 = 200;       % y Position on screen
    width = 900;    
    height = 600;   
    set(gcf, 'units','points','position',[x0,y0,width,height])

%% Save figure
file_name = strrep(file_name, '.csv', '');
save_session = [file_name '.png'];
saveas(gcf, save_session);

end
