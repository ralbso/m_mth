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

default = false(length(data),1);
triggered = false(length(data),1);

licked = false(length(data),1);

short_trials = zeros(length(data),1);
short_position = zeros(length(data),1);

long_trials = zeros(length(data),1);
long_position = zeros(length(data),1);

% Get actual trial number
for i = 1:length(data)
    if mod(num_trials(i), 2) ~= 0
        num_trials(i,1) = 1 + floor(num_trials(i,1)/2);
    else
        num_trials(i,1) = floor(num_trials(i,1)/2);
    end
end

for i = 1:length(data)
    % Acknowledge those licks!
    if lick(i) == 1
        licked(i) = true;
    end
    
    if vr_world(i) == 3
        short_trials(i) = num_trials(i);
        short_position(i) = position(i);
    end
    
    if vr_world(i) == 4
        long_trials(i) = num_trials(i);
        long_position(i) = position(i);
    end
    
    if valve_status(i) ~= 0
        licked(i) = false;
        if valve_status(i) == 2
            default(i) = true;
        elseif valve_status(i) == 1
            triggered(i) = true;
        end
    end
end

% set ylim value to change depending on the amount of trials
total_trials = (num_trials(end));
y = total_trials;

%% Average velocity

tempV = zeros(length(velocity),1);
thresh = 0.7;                       % Slower speed is considered stationary
for i = 1:length(velocity)-1
    if velocity(i) > thresh
        tempV(i) = velocity(i);     % Velocities under thresh will remain as 0
    end
end

velocities = tempV(tempV ~= 0);   % Holds velocities over thresholds
avg_velocity = sum(velocities)/length(velocities);

%% First lick per trial

position_short_vector = zeros(length(data),2);
position_long_vector = zeros(length(data),2);

for i = 1:length(data)
    if short_position(i) >= 200 && licked(i) ~= 0
        position_short_vector(i,:) = [short_position(licked(i)), short_trials(licked(i))];
        [~,first_lick_index_short(i,:),~] = unique(position_short_vector(i));
        first_lick_short(i,:) = position_short_vector(first_lick_index_short(i));
    end
    
    if long_position(i) >= 200 && licked(i) ~= 0
        position_long_vector(i,:) = [long_position(licked(i)), long_trials(licked(i))];
        [~,first_lick_index_long(i,:),~] = unique(position_long_vector(i));
        first_lick_long(i,:) = position_long_vector(first_lick_index_long(i));
    end
end

% stage 5
if max(first_lick_short(:,1)) ~= 0
    average_first_lick_short = mean(first_lick_short(:,1));
else
    average_first_lick_short = 0;
end

if max(first_lick_long(:,1)) ~= 0
    average_first_lick_long = mean(first_lick_long(:,1));
else
    average_first_lick_long = 0;
end

if average_first_lick_long == 0
    average_first_lick = average_first_lick_short;
else
    average_first_lick = (average_first_lick_short + average_first_lick_long)/2;
end

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
    plot(short_position, short_trials, 'bo');
    
    plot(short_position(triggered), short_trials(triggered), 'g*');
    
    plot(short_position(default), short_trials(default), 'r*');
    
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
    plot(long_position, long_trials, 'bo');
    
    plot(long_position(triggered), long_trials(triggered), 'g*');
    
    plot(long_position(default),long_trials(default), 'r*');
    
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
    plot(first_lick_short(:,1), first_lick_short(:,2), 'bo');
    
    % Long track's first licks
    plot(first_lick_long(:,1), first_lick_long(:,2), 'ro');
    
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
