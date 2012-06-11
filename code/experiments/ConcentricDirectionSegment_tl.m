function exp = ConcentricDirectionSegment_tl(exp)
    disp('configuring for tl');
    
    %set the global speed.
    exp.trials.base.extra.directionContrast = 0.2;
    %we're just looking at one combination of contrast and two values of
    %global V...
    globalV = [0.4 -0.4] / (20/3) / 0.1 ;
    
    exp.trials.addBefore('extra.globalDirection', 'extra.globalVScalar', globalV);
    exp.trials.addBefore('extra.globalDirection', {'extra.globalDirection', 'extra.localDirection'}, {{1 1},{-1 -1}});
    exp.trials.remove('extra.globalDirection');
    exp.trials.remove('extra.localDirection');
    
    exp.trials.replace('extra.side', ...
        { 'right', 'left' ... , 'right', 'left' ...
        , 'right', 'left' ... , 'right', 'left' ...
        , 'right', 'left'}, 1, 1); %side is blocked

    exp.trials.add('desiredResponse', 0);
    
    %exp.trials.base.extra.instruction = 'spots';
    %exp.trials.startTrial.message = @()sprintf('Look for the movement of the individual spots.\nPress knob to begin.\n%d blocks in experiment', exp.trials.blocksLeft());
    %exp.trials.endBlockTrial.message = @()sprintf('Take a break, stretch, adjust your chair, etc.\nPress knob to continue.\n%d blocks remain\nLook for the movement of individual spots.', exp.trials.blocksLeft());
    %exp.trials.base.maxResponseLatency = 0.60;

    exp.trials.reps = 1;
    exp.trials.reps = floor(1050 / exp.trials.numLeft());
    exp.trials.blockSize = floor(exp.trials.numLeft() / 6);
    
end