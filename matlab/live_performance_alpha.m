function live_performance(bin)
% LIVE_PERFORMANCE Quick glance at behavior during session.
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
% If no data has been written, wait 0.5 seconds before attempting read
try
    data = dlmread(file_path);
catch
    pause(0.5)
    data = dlmread(file_path);
end

%% Figure setup
figure

% Short trial setup
handles.short_plot = subplot(10,5,[2 28]);
hold on
    xlabel('Location (cm)')
    xlim([50 360])
    ylabel('Trial #')
    ylim([0 200])
    title('Short trials') 
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.432 .445 .036 .48],'FaceColor','black','FaceAlpha',.1)
    hold on;

    % Adds reference lines for reward zone
    vline([320 340], {'k', 'k'})
    annotation('rectangle', [.542 .445 .019 .48],'FaceColor', 'blue','FaceAlpha',.1)
    hold on;

% Long trial setup
handles.long_plot = subplot(10,5,[4 30]);
    xlabel('Location (cm)')
    xlim([50 420])
    ylim([0 200])
    title('Long trials')
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.734 .445 .0325 .48],'FaceColor','black','FaceAlpha',.1)
        
    % Adds reference lines for reward zone box
    vline([380 400], {'k', 'k'})
    annotation('rectangle', [.874 .445 .016 .48],'FaceColor','magenta','FaceAlpha',.1)
    hold on;

handles.first_licks_plot = subplot(10,5,[37 50]);
    legend('Short track', 'Long track')
    xlabel('Location (cm)')
    xlim([190 420])
    ylim([0 200])
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
    
    % Figure parameters
    x0 = 350;       % x position on screen
    y0 = 200;       % 200 Position on screen
    width = 900;    
    height = 600;   
    set(gcf, 'units','points','position',[x0,y0,width,height])

while length(data) <= 191000

    % t = data(:,1);                  % Time
    pos = data(:,2);                  % Position
    % t_frame = data(:,3);            % Time since last frame
    vel = data(:,4);                  % Velocity
    vr_world = data(:,5);             % Current trial (short, long, blackbox)
    valve_stat = data(:,6);           % Valve status
    num_trials = data(:,7);           % Number of trials
    licks = data(:,8);                % Number of licks
    % wheel_vel = data(:,9);          % Wheel velocity

    %% Data on short tracks
    short = vr_world == 3;                         % Short track is track 3
    pos_short = pos(short,:);                      % Location
    num_trials_short = num_trials(short,:);        % Trial #
    licks_short = find(licks(short));              % Indices of licks
    total_short_trials = length(unique(num_trials_short)); % Total trials

    %% Data on long tracks
    long = vr_world == 4;                          % Long track is track 4
    pos_long = pos(long,:);                        % Location
    num_trials_long = num_trials(long,:);          % Trial #
    licks_long = find(licks(long));                % Indices of licks
    total_long_trials = length(unique(num_trials_long));   % Total trials

    %% Valve status
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
    %% Average velocity of mouse
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
    total_trials = (total_long_trials + total_short_trials);

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

    %% Plotting

        % Short trials
        plot(handles.short_plot, pos_licks_short, trial_licks_short, 'bo');
        linkdata on

        plot(handles.short_plot, pos_triggered_short, trial_triggered_short, 'g*');
        linkdata on
        hold on;

        plot(handles.short_plot, pos_short_def, trial_short_def, 'r*');
        linkdata on
        hold on;

        % Long trials
        plot(long_plot, pos_licks_long, trial_licks_long, 'bo');
        linkdata on

        plot(long_plot, pos_triggered_long, trial_triggered_long, 'g*');
        linkdata on
        hold on;

        plot(long_plot, pos_long_def, trial_long_def, 'r*');
        linkdata on
        hold on;

        % First licks
        plot(first_licks_plot, first_licks_short(:,1), first_licks_short(:,2), 'bo');
        linkdata on
        hold on;
        plot(first_licks_plot, first_licks_long(:,1), first_licks_long(:,2), 'ro');
        linkdata on
        hold on;

        % Adds textbox for session information
        axes('Position', [0.02 0.07 1 1], 'Visible', 'off');
        
        try
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
        
        catch
            error('Could not plot data')
        end
    
    data = dlmread(file_path);
end
%% Update graph in real-time

% Idea: If location >= 350 (short trial over), add new data points
%       If location >= 410 (short trial over), add new data points

% if vr_world == 3
%     if pos >= 340
%         data = dlmread(file_path);
%     end
% end
% if vr_world == 5
%     if pos >= 400
%         data = dlmread(file_path);
%     end
% end
% 
% short_all = plot(pos_licks_short, trial_licks_short, 'bo');
% short_trigg = plot(pos_triggered_short, trial_triggered_short, 'g*');
% short_def = plot(pos_short_def, trial_short_def, 'r*');
% long_all = plot(pos_licks_long, trial_licks_long, 'bo');
% long_trigg = plot(pos_triggered_long, trial_triggered_long, 'g*');
% long_def = plot(pos_long_def, trial_long_def, 'r*');
% short_first_lick = plot(first_licks_short(:,1), first_licks_short(:,2), 'bo');
% long_first_lick = plot(first_licks_long(:,1), first_licks_long(:,2), 'ro');

end
