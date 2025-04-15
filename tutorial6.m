%% WELCOME TO THE SIXTH (PSYCHTOOLBOX) MATLAB TUTORIAL! 
clear all; 
close all; 
clc;
rng('default')

% Now that you have learned the basics of MATLAB. It is time to learn about
% Psychtoolbox. Psychtoolbox is MATLAB-compatible software often used to 
% code experiments, because it contains a lot of useful built-in functions
% that are not availble through MATLAB (MATHWORKS) directly.
   
% Important tips:
% OpenGL: graphics software that is installed on most computers 
    % by default. Needed for most Psychooltoxbox to work.
% The documentation for functions in Psychoolbox can be found
    % by typing in help <name of psychtoolbox function> in command line
    % e.g., help Screen
% Alternatively, you can go on http://psychtoolbox.org/docs/Psychtoolbox.html

%% WHAT CAN WE DO WITH PSYCHTOOLBOX?

% Psychtoolbox is software designed for vision and neuroscience research.
% It makes it easy to synthesize and show controlled visual/auditory
% stimuli and interact with the observer. (psychtoolbox.org).

% Psychtoolbox:

% interfaces with MATLAB and the computer hardware to access things like
    % display frame, input devices (keyboard)
    
% To use Psychtoolbox, you need to learn 3 things:
    % 1) MATLAB programming
    % 2) How to create stimuli / measure responses
    % 3) Organizing an experiment


%% ADJUST THESE PARAMETERS!!

% subject information
subjname = '';
subjsex = '';
subjage = nan;

% distance measurements (cm) to calculate degrees of visual angle
ScreenSpecs.distanceFromScreen = 57; % appx distance of eye from screen
ScreenSpecs.screenWidthCm = 30.41;   % must be measured (this is for MacBook
                                     % Pro (13 inch - diag) in cm.

% stimulus parameters
cpd = 1;           % spatial frequency (cycles per degree)
sizedeg = 1;         % degrees of visual angle
orientation = 0; % from vertical 0, 90 right
contrast = 0.5;    % 0 to 1
stimDurationSecs=1;

% trial parameters
nTrials = 10;

%% INITIALIZE DATA TO SAVE

responseData.RT = nan(1,nTrials);
responseData.Answer = nan(1,nTrials);

%% TEMPLATE OF A SIMPLE EXPERIMENT

% Psychtoolbox by default runs tests to make sure that the minotir
% refresh rate interval does not mess up the timing of the experiment.
% Many OS systems are not thoroughly tested with Psychtoolbox, so let's 
% force Psychtoolbox to skip these synchroniziation tests to avoid errors.

KbName('UnifyKeyNames');
Screen('Preference', 'SkipSyncTests', 2) % 2 removes warning completely
                                         % 1 skips with but with warning
                                         
try
    % This is a Psychtoolbox command that checks that OpenGL is installed.
    AssertOpenGL;  % no output if OpenGL is installed
    
    %% Get properties of monitor (size, frame rate, colors)
    
    % Psychtoolbox needs to know which monitor to display stimuli on. Often
    % experimental stimuli are displayed on external monitors connected to
    % the computer that you are running the code from.
    
    screens=Screen('Screens'); % get list of screens/monitors
    screenPointer=max(screens); % set screenNumber to the external (or
                                % only display available)
                                
    % parameters 
    ScreenProperties = Screen('Resolution', screenPointer);  % in pixels
    
    % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
    % That usually means we run on a flat panel with 60 Hz fixed refresh
    % rate:
    if ScreenProperties.hz == 0
        frameRate=60;
        disp('Frame rate not obtainable. Setting default to 60 hz..')
    else
        frameRate = ScreenProperties.hz;
    end
    
    % Let's define colors white and black using Psychtoolbox functions
    % WhiteIndex & BlackIndex. Typically white is 255 and black is 0
    % but this depends on the frame buffer.
    white=WhiteIndex(screenPointer);
    black=BlackIndex(screenPointer);

    % Round gray to integer, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);

    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
        gray=white / 2;
    end

    % Contrast 'inc'rement range for given white and gray values:
    inc=white-gray;
    
    %% Conversion factor of degrees based on monitor specs
    % dvaPerPx = degrees of visual angle per pixel
    % θ = atan((1pixel * cm_ppixel)/ distance_cm
    dvaPerPx = rad2deg(atan(1*(ScreenSpecs.screenWidthCm/ScreenProperties.width))/ScreenSpecs.distanceFromScreen);
    % same: rad2deg(atan2(.5*ScreenSpecs.screenWidthCm, ScreenSpecs.distanceFromScreen)) / (.5*ScreenProperties.width);                 
    
    % stimulus size (in pixels)
    sizep = round(sizedeg/dvaPerPx);
    
    % spatial frequency (converts to cycles/pixel)
    cpp= cpd*(dvaPerPx);
    sf = cpp*(2*pi);  % in radians
    
    %% Open window

    % Open a fullscreen window with a gray background color:
    w=Screen('OpenWindow',screenPointer, gray);
    
    %% Create n image textures tex(n) for each position change of the grating
    
    % Compute each frame of the stimulus and convert the those frames, stored in
    % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
    
    % numFrames determines the speed (larger is slower)
    numFrames=20; % temporal period, in frames, of the drifting grating
    for i=1:numFrames
        
        % complete phase (radians)
        phase=(i/numFrames)*2*pi;  
        
        % orientation from vertical:
        % sets 0 deg to vertical, and 90 deg to right).
        angle=deg2rad(orientation);                         
        
        % calculate gratings in terms of sine, cosine (to later be
        % combined)
        a=cos(angle)*sf;
        b=sin(angle)*sf;
        
        % grating
        % create a the stimulus boundaries
        [x,y]=meshgrid(-300:300,-300:300); 
        
        % create gratinfs (filling boundaries
        grating = contrast*sin(a*x+b*y+phase);
        
        % create gaussian spatial envelope (for soft edges)
        gauss_env = exp(-((x/(sizep/2)).^2)-((y/(sizep/2)).^2))';
        
        m = gauss_env.*grating;
        
        tex(i)=Screen('MakeTexture', w, round(gray+inc*m));
    end
    
    %% Setting stimulus properties based on monitor params
    % Convert movieDuration in seconds to duration in frames to draw:
    stimDurationFrames=round(stimDurationSecs * frameRate);
    stimFrameIndices=mod(0:(stimDurationFrames-1), numFrames) + 1;  

    %%
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);

    %% trial loop"
    for ni=1:nTrials
        
        responseKey=nan; % re-initialize response
    
        %% loop through each frame to update static images (movie)
        % Animation loop:
        for i=1:stimDurationFrames
            
            % Quit experiment if holding down ESC key
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyCode(KbName('ESCAPE'))
                break
            end
            
            % Draw image:
            Screen('DrawTexture', w, tex(stimFrameIndices(i)));
            % Show it at next display vertical retrace. Please check DriftDemo2
            % and later, as well as DriftWaitDemo for much better approaches to
            % guarantee a robust and constant animation display timing! This is
            % very basic and not best practice!
            vbl = Screen('Flip', w);
            
        end     % end of stimulus period
        
        %% TRIAL RESPONSE PERIOD
        
        % hide stimulus (grey screen)
        Screen('Flip',w);
        
        % wait for a valid response
        while ~strcmp(responseKey, 'RightArrow') && ...
                ~strcmp(responseKey, 'LeftArrow')
            [keyIsDown, secs, keyCode] = KbCheck;
            [~, I] = find(keyCode); 
            responseKey = KbName(I); 
        end
        
        % make response output interprettable
        RT = secs - vbl; % response time (s)
        
        % save response output
        responseData.RT(1,ni) = RT;
        if strcmp(responseKey, 'LeftArrow') 
            responseData.Answer(1,ni) = 1;
        elseif strcmp(responseKey, 'RightArrow')
            responseData.Answer(1,ni) = 2;
        end
        
        clear KbCheck;
        
    end         % end of all trials

    %%
    Priority(0);

    % Close all textures. Redundant with 'sca' below, 
    % However, including it will avoid warnings by Psychtoolbox about 
    % unclosed textures.
    Screen('Close');

    % When finished, close window:
    sca;

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    
    sca;         % equivalent to Screen('CloseAll') 
    Priority(0);
    psychrethrow(psychlasterror);
end
