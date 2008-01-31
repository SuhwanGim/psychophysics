function e = SimpleSaccade(varargin)
    e = Experiment(varargin{:});
    
    e.trials.base = SimpleSaccadeTrial...
        ( 'targetLoc', CircularMotion ...
            ( 'radius', 8 ...
            , 'omega', 0 ...
            )...
        , 'targetBlank', 0.5 ...
        , 'targetBlankColor', 0.1 ...
        , 'fixationTime', Inf ...
        , 'fixationOnset', 0.1 ...
        );
    
    e.trials.add('targetLoc.phase', UniformDistribution('lower', 0, 'upper', 2*pi));
    e.trials.add('targetLoc.omega', UniformDistribution('lower', -15/8, 'upper', 15/8));
    
    %target onset hazard from fixation
    e.trials.add('targetOnset', ExponentialDistribution('offset', 0.25, 'tau', 0.4));
    e.trials.add('cueTime', ExponentialDistribution('offset', 0.5, 'tau', 0.4));
    
    %target tracking time
    e.trials.add('targetFixationTime', ExponentialDistribution('offset', 0.4, 'tau', 0.3));
end