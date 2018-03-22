function code = MTH3
    % MTH3   Code for the ViRMEn experiment MTH3.
    %   code = MTH3   Returns handles to the functions that ViRMEn
    %   executes during engine initialization, runtime and termination.


    % Begin header code - DO NOT EDIT
    code.initialization = @initializationCodeFun;
    code.runtime = @runtimeCodeFun;
    code.termination = @terminationCodeFun;
    % End header code - DO NOT EDIT
end



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
   
    % init the serial connection to the microcontroller
    vr.mc = serial('COM4');
    set(vr.mc,'BaudRate',115200);
    set(vr.mc,'TimeOut', 0.001);
    fopen(vr.mc);
    
    % get timer for start of session
    vr.sesstic = tic;
    
    % get information of when the session has started
    session_start = clock;
    
    % read the configuration file and write information to vr structure
    % call this function from initializationCodeFun(vr)

    % obtain config file path for this session
    fid = fopen('c:\vr\vrinput\session_config.csv');
    config_file = textscan(fid,'%s',1,'Delimiter',';');
    fclose(fid);
    
    disp(config_file{1}{1})
    % open config file
    fid = fopen(config_file{1}{1});

    % read head and trial information into vr structure
    vr.config.header = textscan(fid, '%s %s %s %f %s %d %s %d %s %s %s %d %s %s %s %f %s %f %s %s',1,'Delimiter',';','EmptyValue',NaN);
    vr.config.trials = textscan(fid, '%s %f %s %f %s %f %s %f %s %f %s %f %s %f %s %f %s %f %s %f %s %f','Delimiter',';','EmptyValue',NaN);

    % extract information and write it to separate fields in the structure
    vr.config.expname = vr.config.header{2};
    vr.config.s_length = vr.config.header{4};
    vr.config.exp_day = vr.config.header{6};
    vr.config.exp_group = vr.config.header{8};
    vr.config.mouse = vr.config.header{10};
    vr.config.dob = vr.config.header{12};
    vr.config.strain = vr.config.header{14};
    vr.config.stop_thresh = vr.config.header{16};
    vr.config.valve_open = vr.config.header{18};
    vr.config.comments = vr.config.header{20};

    
    % get the length of the trial list of the config file
    vr.config.numtrials = length(vr.config.trials{1});

    % close config file
    fclose(fid);

    % initialise textfields
    % vr = init_txtfeedback( vr );
    
    % initialise a trial number counter. 
    vr.trial_counter = 1;
    
    % keeps track of line in config file
    vr.config_counter = 1;
    
    % reward counter
    vr.reward_counter = 0;
    
    % flag that indicates if the animal is currently stationary
    vr.stationary = 0;
    
    % flag to indicate if a reward has been dispensed in this trial
    vr.rew_received = 0;
    
    % initialise a counter that keeps track of licks detected in every
    % frame (should never really exceed 1 as it is unlikely that a mouse licks more than once per frame)
    vr.licknum = 0;
    
    % total number of licks detected in this session
    vr.totlicknum = 0;

    % indicator whether the valve is open or closed
    vr.valvestat = 0;

    % flag to indicate whether a position is to be reset.
    vr.reset_pos = false;
       
    % this value stores the maximum latency that has occured during the
    % currently running session
    vr.maxlatency = 0.0;
      
    % helper variable to calculate new location based on treadmill
    % displacement
    vr.new_pos = 0.0;
    
    vr.blackbox_move_ref = 0;
    
    % timers
    vr.valvetic = 0.0;
     
    % indicate the line from which the information for the current trial is
    % taken
    vr.curconfigtrial = 1;
    
    % set starting track
    vr.currentWorld = vr.config.trials{2}(vr.curconfigtrial);
    
    % intialise random number generator
    rng('shuffle');
    
    % initialise with 0 as its sometimes NaN otherwise
    vr.velocity = [0 0 0 0];
    
    % number of frames in session
    vr.numframes = 0;
    
    % actual velocity of the wheel (required for openloop experiments)
    vr.wheel_velocity = 0;
    
    % below are path and filename for testing the VR
    vr.config.fdir = 'c:\vr\vroutput';
    vr.config.fname = strcat(vr.config.expname{1}, '_', num2str(session_start(1)), num2str(session_start(2)), num2str(session_start(3)), '_', num2str(session_start(4)), num2str(session_start(5)),'.csv');
    
    % set up UDP connection to control scanbox
    %vr.scanbox_udb = udp('18.93.13.93','RemotePort',7000);
    %fopen(vr.scanbox_udb);
    %fprintf(vr.scanbox_udb,'AM01'); % set animal id field
    %fprintf(vr.scanbox_udb,'U0000'); % set exp id field
    %fprintf(vr.scanbox_udb,'G'); % start scanbox
    pause(1.4);   % this pause is required to allow the microcontroller to reboot and flush the buffers and give the NLW scope time to start acquiring
    % create raw datafile but don't write anything yet (that happens during
    % runtime)
    cd(vr.config.fdir);
    resfid = fopen(vr.config.fname,'w');
    fclose(resfid);
    
    % initialise data structure to hold data in memory
    vr.data = zeros(500000, 9);
    vr.line = 1;
    
    vr.live_data = zeros(5000,7);
    vr.live_line = 1;
    
    %% In case of problems, comment this whole block
    % initialize figure for performance monitoring
    figure('Position', [100 100 900 900]);
    % set(gcf,'Renderer','OpenGL');

    % Short trial setup
    % axes('Position', [left bottom width height])
    vr.short_plot = axes('Position', [0.07 0.62 0.9 0.35]);

    vr.short_plot.XLimMode = 'manual';
    vr.short_plot.XLim = [50 350];
    vr.short_plot.YLim = [0 50];
    vr.short_plot.XLabel.String = 'Location (cm)';
    vr.short_plot.YLabel.String = 'Trial #';
    vr.short_plot.Title.String = 'Short trials'; 

    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle', [0.52 0.62 0.12 0.35],'FaceColor','black','FaceAlpha',.1)

    % Adds reference lines for reward zone
    vline([320 340], {'k', 'k'})
    annotation('rectangle', [0.88 0.62 0.06 0.35],'FaceColor', 'blue','FaceAlpha',.1)

    % Long trial setup
    vr.long_plot = axes('Position', [0.07 0.195 0.9 0.35]);

    vr.long_plot.XLimMode = 'manual';
    vr.long_plot.XLim = [50 410];
    vr.long_plot.YLim = [0 50];
    vr.long_plot.XLabel.String = 'Location (cm)';
    vr.long_plot.YLabel.String = 'Trial #';
    vr.long_plot.Title.String = 'Long trials';

    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[0.445 0.195 0.1 0.35],'FaceColor','black','FaceAlpha',.1)

    % Adds reference lines for reward zone box
    vline([380 400], {'k', 'k'})
    annotation('rectangle', [0.895 0.195 0.05 0.35],'FaceColor','magenta','FaceAlpha',.1)
    
%     vr.trials_per_min = 0;
%     vr.trials = 0;
%     vr.counter = 0;
    vr.lick_counter = 0;
    
    stats = annotation('textbox', [0.15 0.1 0.2 0], 'string', 'Trials per minute: ');
    stats.FontSize = 14;
    stats.LineStyle = 'none';
    
    vr.is_blackbox = false;
    
    %%
    vr.blackbox_3_tic = tic;
    
end

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    % send pulse to microcontroller at the beginning of each frame to
    % trigger the eye-tracking camera
    % fprintf(vr.mc, '1');
    
    vr.numframes = vr.numframes+1;
    
    % initialise vector that will hold serial connection input
    A = [];
    % keep count of how many licks were detected
    vr.licknum = 0;
    
    %indicate if a lick was detected in this frame
    has_licked = false;
    
    % Read input from serial connection
    if vr.mc.BytesAvailable > 0
        [A, count] = fread(vr.mc, vr.mc.BytesAvailable,'uint8');
        for i = 1:size(A,1)
            if A(i) > 1
                %disp('lick')
                has_licked = true;
                A(i) = NaN;
                vr.licknum = vr.licknum + 1;
            end
        end
    else
        count = 0;
    end
    
    % calculate displacement in VR depending on the information from the
    % rotary encoder
    loc_displace = (nansum(A) + (nansum(A) - (count-vr.licknum)))*vr.config.trials{6}(vr.curconfigtrial);
    
    % check if openloop is set to a speed other than -1 (in which case its
    % closed loop execution
    if  vr.config.trials{20}(vr.curconfigtrial)==-1
        % avoid division by zero which can be the case if rendering
        % stutters
        if vr.dt ~= 0.0
            vr.velocity = [0 -(loc_displace*0.012566)/vr.dt 0 0];
            vr.wheel_velocity = -1;
        end
    else  
        vr.velocity = [0 vr.config.trials{20}(vr.curconfigtrial) 0 0];
        if vr.dt ~= 0.0
            vr.wheel_velocity = -(loc_displace*0.012566)/vr.dt;
        end
    end
     
    % turn optogenetics light on/off
    %if (vr.config.trials{4}(vr.curconfigtrial) == 1) % && (vr.velocity(2) > 2.0)
    %    fprintf(vr.mc, 'b');
    %else
    %    fprintf(vr.mc, 'n');
    %end
    
    % put mouse in black box if it licks after the landmark but before the
    % reward
    if has_licked && vr.config.trials{4}(vr.curconfigtrial)==0 && vr.position(2) >= vr.config.trials{16}(vr.curconfigtrial) && vr.position(2) <= vr.config.trials{12}(vr.curconfigtrial)
        % set position to new world 
        vr.currentWorld = 5;
        % set current position as reference point: if they move outside a
        % certain tolerance, the blackout timer is reset
        vr.blackbox_move_ref = vr.position(2);
        % start blackbox timer
        vr.blackbox_3_tic = tic;
        % update trial counter
        vr.trial_counter = vr.trial_counter + 1;
    end
    
    % dispense reward and put mouse in blackbox if it licks in the reward
    % zone
    if (has_licked && vr.position(2) >= vr.config.trials{12}(vr.curconfigtrial)) && (vr.position(2) <= vr.config.trials{14}(vr.curconfigtrial))... 
            && (vr.rew_received == 0 && vr.currentWorld~=5) 
        
        % open valve
        if vr.config.trials{8}(vr.curconfigtrial) == 1
            fprintf(vr.mc, 'r');
        end
        vr.reward_counter = vr.reward_counter + 1;
        vr.valvestat = 1;
        vr.rew_received = 1;
        
        %start timer to control how long valve will be open
        vr.valvetic = tic; 
        % set position to new world 
        vr.currentWorld = 5;
        % set current position as reference point: if they move outside a
        % certain tolerance, the blackout timer is reset
        vr.blackbox_move_ref = vr.position(2);
        % start blackbox timer
        vr.blackbox_3_tic = tic;
        % update trial counter
        vr.trial_counter = vr.trial_counter + 1;
    end
    
    if (vr.rew_received == 0 && vr.position(2) >= vr.config.trials{18}(vr.curconfigtrial) && vr.currentWorld~=5)
        
        % open valve
        if vr.config.trials{8}(vr.curconfigtrial) == 1
            fprintf(vr.mc, 'r');
        end
        vr.reward_counter = vr.reward_counter + 1;
        vr.valvestat = 2;
        vr.rew_received = 1;
        
        %start timer to control how long valve will be open
        vr.valvetic = tic; 
        % reset position
        vr.position(2) = 0;
        % set position to new world 
        vr.currentWorld = 5;
        % set current position as reference point: if they move outside a
        % certain tolerance, the blackout timer is reset
        vr.blackbox_move_ref = vr.position(2);
        % start blackbox timer
        vr.blackbox_3_tic = tic;
        % update trial counter
        vr.trial_counter = vr.trial_counter + 1;
    end
    
    if vr.currentWorld==5
        vr.is_blackbox = true;
        % if animal licks in blackbox: reset timer
        if vr.config.trials{22}(vr.curconfigtrial)==1
            if vr.licknum > 0
                vr.blackbox_3_tic = tic;
            end
            if abs(vr.position(2)-vr.blackbox_move_ref) > 5
                vr.blackbox_3_tic = tic;
                vr.blackbox_move_ref = vr.position(2);
            end
        end
        if toc(vr.blackbox_3_tic) > 3
            % determine which line in the config file we are currently on
            vr.curconfigtrial = mod(vr.config_counter,vr.config.numtrials) +1;
            % set position to new world 
            vr.currentWorld = vr.config.trials{2}(vr.curconfigtrial);
            % reset position
            vr.position(2) = randi([50,100]);
            %vr.position(2) = randi([0,50]);
            % reset flag to indicate that another reward can be dispensed
            vr.rew_received = 0; 
            % update trial counter
            vr.trial_counter = vr.trial_counter + 1;
            vr.config_counter = vr.config_counter + 1;
        end
    end
    
    % check for elapsed time since opening valve and if it exceeds the
    % defined time, close valve
    if vr.valvestat > 0 && toc(vr.valvetic) > vr.config.valve_open
        fprintf(vr.mc, 't');  
        vr.valvestat = 0;
        vr.valvetic = 0.0;
    end

    % determine whether the latency of the current frame is higher that that of
    % the maximum. Ignore first 500 ms as latencies can be high while the VR is
    % being initialised
    if (vr.dt > vr.maxlatency) && (str2double(datestr(now - vr.timeStarted,'SS')) > 0.5)
        vr.maxlatency = vr.dt;
    end

    % Reset location if mouse reaches end of track (defined by reset point
    % in config file
    if (vr.position(2) > vr.config.trials{10}(vr.curconfigtrial)) && vr.currentWorld ~= 5
        % determine which line in the config file we are currently on
        vr.curconfigtrial = mod(vr.trial_counter,vr.config.numtrials) +1;
        %disp(vr.curconfigtrial);
        % set position to new world 
        %vr.currentWorld = vr.config.trials{2}(vr.curconfigtrial);
        vr.currentWorld = 5;
        % reset position
        vr.position(2) = 0;
        % reset flag to indicate that another reward can be dispensed
        vr.rew_received = 0; 
        % update trial counter
        vr.trial_counter = vr.trial_counter + 1;
        % set blackbox reference to last location
        vr.blackbox_move_ref = vr.position(2);
        % start blackbox timer
        vr.blackbox_3_tic = tic;
        % update trials per minute
        % vr.trials = vr.trials + 1;
           
    end
    
    % store time values as close to vr.data's as possible
    % secs = round(toc(vr.sesstic));
    
    vr.data(vr.line,:) = [toc(vr.sesstic), vr.position(2), vr.dt, vr.velocity(2), vr.currentWorld, vr.valvestat, vr.trial_counter, vr.licknum, vr.wheel_velocity];    
    vr.line = vr.line + 1;
    
    % Set trial counter to ignore blackbox as an actual trial
    if vr.is_blackbox
        trial_counter = 1 + floor(vr.trial_counter/2);
    else
        trial_counter = floor(vr.trial_counter/2);
    end
    
%     if mod(secs,60) == 0
%         vr.trials_per_min = vr.trial_counter/60;
%     end
%         
    vr.lastWorld = 0;
    vr.lastPosition = 0;
    
    if vr.valvestat ~= 0
        vr.lastWorld = vr.data(vr.line-2,5);
        vr.lastPosition = vr.data(vr.line-2,2);
    end
    
    if trial_counter > 150
        vr.short_plot.YLim = [151 200];
        vr.long_plot.YLim = [151 200];
    elseif trial_counter > 100 && trial_counter <= 150
        vr.short_plot.YLim = [101 150];
        vr.long_plot.YLim = [101 150];
    elseif trial_counter > 50 && trial_counter <= 100
        vr.short_plot.YLim = [51 100];
        vr.long_plot.YLim = [51 100];
    end

    if lick_num ~= 0
        vr.live_data(vr.lick_line,:) = [vr.position(2), vr.lastPosition, vr.currentWorld, vr.lastWorld, vr.valvestat, trial_counter, vr.licknum];
        vr.live_line = vr.live_line + 1;
        vr.lick_counter = vr.lick_counter + 1;
    end
    
    if vr.lick_counter >= 50
        vr.lick_counter = 0;
        vr.live_line = 0;
        % do or do not, there is no
        try
           live_performance(vr.live_data, vr.short_plot, vr.long_plot)
        catch
           dlmwrite(vr.config.fname,vr.data(1:vr.numframes,:),';');
           fclose(vr.mc);
           delete(vr.mc);
           warning('error plotting live performance')
        end
    end

    % check if maximum session length is reached and terminate VR if it is
    if toc(vr.sesstic) > (vr.config.s_length*60)
        disp('SESSION COMPLETE')
        vr.experimentEnded = true;
    end
    
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
    %fprintf(vr.scanbox_udb,'S'); % send signal to stop acquisition
    fprintf(vr.mc, 'n');
    disp(num2str(vr.reward_counter));
    fclose(vr.mc);
    delete(vr.mc);
    
    dlmwrite(vr.config.fname,vr.data(1:vr.numframes,:),';');
    % write to raw datafile
    %for i = 1:length(vr.data)
    %    if vr.data(i, 1) > 0
    %        resfid = fopen(vr.config.fname,'a');
    %        fprintf(resfid,'%4.6f;%3.6f;%1.6f;%3.4f;%d;%d;%d;%d;%3.4f\n', vr.data(i,:)); % this whole way of writing to disk is terribly slow and should be fixed. LF170359
    %        fclose(resfid);
    %    end
    %end
    
    performance(0)
end
