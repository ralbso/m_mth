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
    config_file = 'C:\vr\vrinput\sesion_config.csv';
    cfid = fopen(config_file);
    conf = textscan(cfid,'%s');
    
    [~,sess_config_name,~] = fileparts(char(conf{1}));
    sess_config = -1;
end

% Pop-up box for .csv file selection
if bin == 1
    [file_name, path] = uigetfile('*.csv', 'Select raw data', 'C:\vr\vroutput\');
    if isequal(file_name, 0)
        error('File selection was cancelled.')
    end
    
    [sess_config_name,~] = uigetfile('*.csv', 'Select config file', 'C:\vr\vrinput\');
    if isequal(sess_config_name, 0)
        error('File selection was cancelled.')
    end
    [~,sess_config_name,~] = fileparts(sess_config_name);
end

switch sess_config_name
    case 'MTH3_stage2'
        sess_config = 1;
    case 'MTH3_stage5'
        sess_config = 2;
    case 'MTH3_s5r'
        sess_config = 2;
    case 'MTH3_s5r_gm'
        sess_config = 2;
    case 'MTH3_VD_config'
        sess_config = 6;
    case 'MTH3_VD'
        sess_config = 6;
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
licks = data(:,8);               % Number of licks
% wheel_vel = data(:,9);        % Wheel velocity

lines = length(data);

%% Your run of the mill setup for quick n' dirty plots

if sess_config == 1 || sess_config == 2
    short_trials = vr_world == 3;
    short_position = position(short_trials,:);
    short_num_trials = num_trials(short_trials,:);
    short_licks = find(licks(short_trials));
    total_short_trials = length(unique(short_num_trials));
    landmark_location = 200;
    
    long_trials = vr_world == 4;
    long_position = position(long_trials,:);
    long_num_trials = num_trials(long_trials);
    long_licks = find(licks(long_trials,:));
    total_long_trials = length(unique(long_num_trials));
    landmark_location = 200;
    
end

if sess_config == 6
    short_trials = vr_world == 7;
    short_position = position(short_trials,:);
    short_num_trials = num_trials(short_trials,:);
    short_licks = fidn(licks(short));
    total_short_trials = length(unique(num_trials_short));
    landmark_location = 200;
    
    long_trials = vr_world == 9;
    long_position = position(long_trials,:);
    long_num_trials = num_trials(long_trials);
    long_licks = find(licks(long_trials,:));
    total_long_trials = length(unique(long_num_trials));
    landmark_location = 200;
    
end

% set ylim value to change depending on the amount of trials
total_trials = (num_trials(end));
y = total_trials;

%% Reward: Triggered vs. Default @ Madison Square Garden
valve_change = diff(valve_status);

temp_triggered = zeros(lines,1);
for i = 1:lines
    if valve_change(i) == 1
        temp_triggered(i) = valve_change(i);
    end
end

temp_default = zeros(lines,1);
for i = 1:lines
    if valve_change(i) == 2
        temp_triggered(i-1) = 1;
    end
end

temp_triggered = logical([temp_triggered;0]);
temp_default = logical([temp_default;0]);

triggered_short_index = find(temp_triggered(short_trials));
triggered_long_index = find(temp_triggered(long_trials));
default_short_index = find(temp_default(short_trials));
default_long_index = find(temp_default(long_trials));

%% Average velocity

tempV = zeros(length(velocity),1);
thresh = 0.7;                       % Slower speed is considered stationary
for i = 1:length(velocity)-1
    if velocity(i) > thresh
        tempV(i) = velocity(i);     % Velocities under thresh will remain as 0
    end
end

velocities = tempV(tempV ~= 0);   % Holds velocities over thresholds
average_velocity = sum(velocities)/length(velocities);

%% Set up data for plotting
% Licks throughout the trial
short_position_licks = short_position(short_licks);
short_trial_licks = num_trials_short(short_licks);
long_position_licks = long_position(long_licks);
long_trial_licks = num_trials_long(long_licks);

% Triggered rewards
short_position_triggered = short_position(triggered_short_index);
short_trial_triggered = short_num_trials(triggered_short_index);
long_position_triggered = long_position(triggered_long_index);
long_trial_triggered = long_num_trials(triggered_long_index);

% Default rewards
short_position_default = short_position(default_short_index);
short_trial_default = short_num_trials(default_short_index);
long_position_default = long_position(default_long_index);
long_trial_default = long_num_trials(default_long_index);

%% First lick per trial

short_trial_position_matrix = [short_position_licks(short_position_licks >= landmark_location), ...
    short_trial_licks(short_position_licks >= landmark_location)];
[~,is,~] = unique(short_trial_licks(short_position_licks >= landmark_location));
short_first_licks = short_trial_position_matrix(is,:);

long_trial_position_matrix = [long_position_licks(long_position_licks >= landmark_location), ...
    long_trial_licks(long_position_licks >= landmark_location)];
[~,il,~] = unique(long_trial_licks(long_position_licks >= landmark_location));
long_first_licks = long_trial_position_matrix(il,:);

if max(short_first_licks(:,1)) ~= 0
    short_average_first_lick = mean(short_first_licks(:,1));
else
    short_average_first_lick = 0;
end

if max(long_first_licks(:,1)) ~= 0
    long_average_first_lick = mean(long_first_licks(:,1));
else
    long_average_first_lick = 0;
end

if average_first_lick_long == 0
    average_first_licks = average_frist_lick_short;
else
    average_first_licks = (short_average_first_lick + long_average_first_lick)/2;
end

median_first_licks = median([short_first_licks(:,1); long_first_licks(:,1)], 'omitnan');

%% Figure setup
figure
    
    % Short trials
    subplot(10,5,[2 28])
    
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
    
    % Plot licks on short track
    line('XData',[short_position_licks,short_position_licks],'YData',[short_trial_licks,short_trials_licks], 'LineStyle','none','Marker','o','MarkerEdgeColor','b');
    
    line('XData',[short_position_triggered,short_position_triggered],'YData',[short_trial_triggered,short_trial_triggered],'LineStyle','none','Marker','*','MarkerEdgeColor','g');
    
    line('XData',[short_position_default,short_position_default],'YData',[short_trial_default,short_trial_default],'LineStyle','none','Marker','*','MarkerEdgeColor','r');
    
    % Long trials
    subplot(10,5,[4 30])
    
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
    
    % Plot licks on long track
    line('XData',[long_position_licks,long_position_licks],'YData',[long_trial_licks,long_trials_licks], 'LineStyle','none','Marker','o','MarkerEdgeColor','b');
    
    line('XData',[long_position_triggered,long_position_triggered],'YData',[long_trial_triggered,long_trial_triggered],'LineStyle','none','Marker','*','MarkerEdgeColor','g');
    
    line('XData',[long_position_default,long_position_default],'YData',[long_trial_default,long_trial_default],'LineStyle','none','Marker','*','MarkerEdgeColor','r');
    
    % First licks
    subplot(10,5,[37 50])
    
    legend('Short track', 'Long track')
    xlabel('Location (cm)')
    xlim([190 420])
    ylim([0 y])
    title('First licks')
    
    vline([200 240], {'k', 'k'})
    annotation('rectangle', [.32 .11 .1052 .227], 'FaceColor','black','FaceAlpha',.1)
    
    vline([320 340], {'k', 'k'})
    annotation('rectangle', [.6393 .11 .0522 .227], 'FaceColor','blue','FaceAlpha',.1)
    
    vline([380 400], {'k', 'k'})
    annotation('rectangle', [.799 .11 .0522 .227], 'FaceColor','magenta','FaceAlpha',.1)
    
    % Short track's first licks
    line('XData',[short_first_licks(:,1),short_first_licks(:,1)],'YData',[short_first_licks(:,2),short_first_licks(:,2)],'LineStyle','none','Marker','o','MarkerEdgeColor', 'b');
    
    % Long track's first licks
    line('XData',[long_first_licks(:,1),long_first_licks(:,1)],'YData', [long_first_licks(:,2),long_first_licks(:,2)],'LineStyle','none','Marker','o','MarkerEdgeColor','r');
    
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
        strcat(num2str(average_velocity), ' cm/s');
        '';
        'Mean first lick:';
        strcat(num2str(average_first_licks));
        '';
        'Median first lick:'
        strcat(num2str(median_first_licks));};
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
