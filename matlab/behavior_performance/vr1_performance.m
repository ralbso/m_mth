function performance(bin)
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
    config_file = 'C:\vr\vrinput\session_config.csv';
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
    [sess_config_name, ~] = uigetfile('*.csv', 'Select config file', 'C:\vr\vrinput\');
    if isequal(sess_config_name, 0)
        error('File selection was cancelled.')
    end
    [~,sess_config_name,~] = fileparts(sess_config_name);
end

% determine which config file was used for session
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

% Arg can only be 0 or 1!
if bin > 1 || bin < 0
    error('Arg can only be 0 or 1.')
end

file_path = fullfile(path, file_name); 

%% Load .csv with session data
data = dlmread(file_path);

% time = data(:,1);               % Time
pos = data(:,2);                % Position
% t_frame = data(:,3);            % Time since last frame
vel = data(:,4);                % Velocity
vr_world = data(:,5);           % Current trial (short, long, blackbox)
valve_stat = data(:,6);         % Valve status
num_trials = data(:,7);         % Number of trials
licks = data(:,8);              % Number of licks
% wheel_vel = data(:,9);          % Wheel velocity

% Data on short tracks
if sess_config == 1 || sess_config == 2
    short = vr_world == 3;                         % Short track is track 3
    pos_short = pos(short, :);                     % Location
    num_trials_short = num_trials(short, :);       % Trial #
    licks_short = find(licks(short));              % Indices of licks
    total_short_trials = length(unique(num_trials_short)); % Total trials

    % Data on long tracks
    long = vr_world == 4;                          % Long track is track 4
    pos_long = pos(long, :);                       % Location
    num_trials_long = num_trials(long, :);         % Trial #
    licks_long = find(licks(long));                % Indices of licks
    total_long_trials = length(unique(num_trials_long));    % Total trials
end

if sess_config == 6
    short = vr_world == 7;                         % Short track (tracks are samme length) is track 7
    pos_short = pos(short, :);                     % Location
    num_trials_short = num_trials(short, :);       % Trial #
    licks_short = find(licks(short));              % Indices of licks
    total_short_trials = length(unique(num_trials_short)); % Total trials

    % Data on long tracks
    long = vr_world == 9;                          % Long track is track 9
    pos_long = pos(long, :);                       % Location
    num_trials_long = num_trials(long, :);         % Trial #
    licks_long = find(licks(long));                % Indices of licks
    total_long_trials = length(unique(num_trials_long));    % Total trials
    
end

% Valve status
valve_change = diff(valve_stat);               % Only valve changes matter to us

temp_trig = zeros(length(valve_change),1);     % Convert into logical
for t = 1:length(valve_change)
    if valve_change(t) == 1
        temp_trig(t) = valve_change(t);
    end
end

temp_def = zeros(length(valve_change),1);
for t = 1:length(valve_change)                 % Convert into logical
    if valve_change(t) == 2
        temp_def(t-1) = 1;
    end
end

temp_trig = logical([temp_trig;0]);
temp_def = logical([temp_def;0]);

trig_short_ind = find(temp_trig(short));
trig_long_ind = find(temp_trig(long));
default_short_ind = find(temp_def(short));
default_long_ind = find(temp_def(long));

% Honorable mention to Quique, who helped me refresh for loops in MATLAB
% Average velocity of mouse
tempV = zeros(length(vel),1);
thresh = 0.7;               % Slower speed is considered stationary
for t = 1:length(vel)-1
    if vel(t) > thresh
        tempV(t) = vel(t);  % Velocities under thresh will remain as 0
    end
end

vels = tempV(tempV ~= 0);   % Holds velocities over thresholds
avg_vel = sum(vels)/length(vels);

%% For plotting
% Licks along the tracks
pos_licks_short = pos_short(licks_short);
trial_licks_short = num_trials_short(licks_short);
pos_licks_long = pos_long(licks_long);
trial_licks_long = num_trials_long(licks_long);

% Triggered rewards
pos_triggered_short = pos_short(trig_short_ind);
trial_triggered_short = num_trials_short(trig_short_ind);
pos_triggered_long = pos_long(trig_long_ind);
trial_triggered_long = num_trials_long(trig_long_ind);

% Default rewards
pos_short_def = pos_short(default_short_ind);
trial_short_def = num_trials_short(default_short_ind);
pos_long_def = pos_long(default_long_ind);
trial_long_def = num_trials_long(default_long_ind);

% set ylim value to change depending on the amount of trials
y = ((total_long_trials + total_short_trials)*2);

%% First licks
%what is 200?? in threshold below?...need to change depending on track
%type...
pos_trial_mat_short = [pos_licks_short(pos_licks_short>=200) trial_licks_short(pos_licks_short>=200)];
[~,is,~] = unique(trial_licks_short(pos_licks_short>=200));
first_licks_short = pos_trial_mat_short(is,:);

pos_trial_mat_long = [pos_licks_long(pos_licks_long>=200) trial_licks_long(pos_licks_long>=200)];
[~,il,~] = unique(trial_licks_long(pos_licks_long>=200));
first_licks_long = pos_trial_mat_long(il,:);

try
    if max(first_licks_short(:,1)) ~= 0
        avg_first_lick_short = mean(first_licks_short(:,1));
    else
        avg_first_lick_short = 0;
    end
catch
    avg_first_lick_short = 0;
end

try
    if max(first_licks_long(:,1)) ~= 0
        avg_first_lick_long = mean(first_licks_long(:,1));
    else
        avg_first_lick_long = 0;
    end
catch
    avg_first_lick_long = 0;
end

if avg_first_lick_long == 0
    avg_first_licks = avg_first_lick_short;
else
    avg_first_licks = (avg_first_lick_short + avg_first_lick_long)/2;
end

med_first_licks = median([first_licks_short(:,1); first_licks_long(:,1)], 'omitnan');

%% Figure setup
figure
    
    % Short trials
    ax1= subplot(10,5,[2 28]);
    plot(pos_licks_short, trial_licks_short, 'bo') 
    
    xlabel('Location (cm)')
    xlim([50 360])
    ylim([0 y])
    ylabel('Trial #') 
    title('Short trials') 
    
    % Adds reference lines for landmark
%     vline([200 240], {'k', 'k'})
    annotation('rectangle',[.432 .445 .036 .48],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone
%     vline([320 340], {'k', 'k'})
    annotation('rectangle', [.542 .445 .019 .48],'FaceColor', 'blue','FaceAlpha',.1)
    hold on;
    
    plot(pos_triggered_short, trial_triggered_short, 'g*')
    hold on;
    
    plot(pos_short_def, trial_short_def, 'r*')
    hold on;
    
    % Long trials
    ax2 = subplot(10,5,[4 30]);
    plot(pos_licks_long, trial_licks_long, 'bo')
    
    xlabel('Location (cm)')
    xlim([50 420])
    ylim([0 y])
    title('Long trials')
    
    % Adds reference lines for landmark
%     vline([200 240], {'k', 'k'})
    annotation('rectangle',[.734 .445 .0325 .48],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone box
%     vline([380 400], {'k', 'k'})
    annotation('rectangle', [.874 .445 .016 .48],'FaceColor','magenta','FaceAlpha',.1)
    hold on;
    
    plot(pos_triggered_long, trial_triggered_long, 'g*')
    hold on;
    
    plot(pos_long_def, trial_long_def, 'r*')
    hold on;
    
    % First licks
    ax3 = subplot(10,5,[37 50]);
    plot(first_licks_short(:,1), first_licks_short(:,2), 'bo');
    hold on;
    plot(first_licks_long(:,1), first_licks_long(:,2), 'ro');
    hold on;
    
    legend('Short track', 'Long track')
    xlabel('Location (cm)')
    xlim([190 420])
    ylim([0 y])
    title('First licks')
    
%     vline([200 240], {'k', 'k'})
    annotation('rectangle', [.318 .109 .107 .23], 'FaceColor','black','FaceAlpha',.1)
    hold on;
    
%     vline([320 340], {'k', 'k'})
    annotation('rectangle', [.6393 .109 .0523 .23], 'FaceColor','blue','FaceAlpha',.1)
    hold on;
    
%     vline([380 400], {'k', 'k'})
    annotation('rectangle', [.799 .109 .0523 .23], 'FaceColor','magenta','FaceAlpha',.1)
    hold on;
    
    vline(avg_first_lick_short, 'b', 'Mean')
    vline(avg_first_lick_long, 'r', 'Mean')
    hold on;
    
    % Adds textbox for session information
    axes('Position', [0.02 0.07 1 1], 'Visible', 'off');
    descr = {'Short trials:';
        strcat(num2str(total_short_trials), ' trials');
        '';
        'Long trials:';
        strcat(num2str(total_long_trials), ' trials');
        '';
        'Average velocity:';
        strcat(num2str(avg_vel), ' cm/s');
        '';
        'Mean first lick:';
        strcat(num2str(avg_first_licks));
        '';
        'Median first lick:'
        strcat(num2str(med_first_licks));};
    text(0.025,0.4,descr)
    
    % Figure parameters
    x0 = 300;       % x position on screen
    y0 = 125;       % y Position on screen
    width = 900;    
    height = 600;   
    set(gcf, 'units','points','position',[x0,y0,width,height])

%% Save figure
file_name = strrep(file_name, '.csv', '');
save_session = [file_name '.png'];
saveas(gcf, save_session);

end
