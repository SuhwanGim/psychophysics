function e = GloLoCued(varargin)
    %this randomizer needs to runa bunch of QUESTs in 

    e = Experiment...
        ( 'params', struct...
            ( 'skipFrames', 1  ...
            , 'priority', 9 ...
            , 'hideCursor', 0 ...
            , 'doTrackerSetup', 0 ...
            , 'input', struct ...
                ( 'keyboard', KeyboardInput() ...
                , 'knob', PowermateInput() ...
                ) ...
            )...
        , varargin{:} ...
        );
    
    e.trials.base = GloLoCuedTrial...
        ( 'barOnset', 0 ...                         %randomized below
        , 'barCueDuration', 1/30 ...
        , 'barCueDelay', 0.3 ...
        , 'barFlashColor', [0.75 0.75 0.75] ...
        , 'barFlashDuration', 1/30 ...
        , 'barLength', 2 ...
        , 'barWidth', 0.15 ...
        , 'barPhase', 0 ...                         %randomized below
        , 'barPhaseStep', 2*pi/1024 ...
        , 'barRadius', 8 ...
        , 'fixationPointSize', 0.1 ...
        , 'motion', InsertPulse('process', CircularCauchyMotion ...
            ( 'angle', 90 ...
            , 'color', [0.25; 0.25; 0.25] ...
            , 'dt', 0.2 ...
            , 'n', 5 ...
            , 'phase', 0 ...                        %randomized below
            , 'radius', 5 ...
            , 't', 0.2 ...
            , 'dphase', 1/5 ...
            , 'wavelength', 0.375 ...
            , 'width', 1 ...
            , 'duration', 0.075 ...
            , 'velocity', 5 ...
            , 'order', 4 ...
            ))...
        );
        
    
    %The range of temporal offsets:
    %from the onset of the second flash to the onset of the fourth flash is
    %49 timepoints at 120 fps
    e.trials.add('barOnset', e.trials.base.motion.process.t + e.trials.base.motion.process.dt * linspace(0,3,4));
    
    %The bar origin is random around the circle and orientation follows
    %motion phase, angle, bar onset, bar phase
    e.trials.add({'motion.process.phase', 'motion.process.angle'}, @(b)num2cell(rand()*2*pi * [1 180/pi] + [0 90]));
    
    e.trials.add({'motion.process.velocity', 'motion.process.dphase'}, {{-e.trials.base.motion.process.velocity, -e.trials.base.motion.process.dphase}, {e.trials.base.motion.process.velocity, e.trials.base.motion.process.dphase}});
    
    %bar phase is sampled in a range...
    e.trials.add('extra.barStepsAhead', linspace(-0.75, 1, 8));
    %that is centered on the location of the bar.
    e.trials.add('barPhase', @(b)b.extra.barStepsAhead*b.motion.process.dphase + b.motion.process.phase + (b.barOnset-b.motion.process.t(1))*b.motion.process.dphase ./ b.motion.process.dt);
            
    %the message to show between blocks.
    e.trials.blockTrial = MessageTrial('message', @()sprintf('Press knob to continue. %d blocks remain', e.trials.blocksLeft()));
    
    e.trials.fullFactorial = 1;
    e.trials.reps = 3;
    e.trials.blockSize = 96;
    
    %tell the randomizer how to randomize the trial each time.
    e.trials.add('motion.pulseAt', [1 2 3]);

    %Three kinds of pulses: faster, slower, non.
    e.trials.add('motion.pulse', ...
        { struct() ...
        , @(b)struct('wavelength', 0.75, 'color', [0.125 0.125 0.125]', 'velocity', 10 * sign(b.motion.process.velocity)) ...
        , @(b)struct('wavelength', 0.1875, 'color', [0.5 0.5 0.5]', 'velocity', 2.5 * sign(b.motion.process.velocity)) ...
        });
