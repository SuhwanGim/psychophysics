function [this, canvas_, events_] = mainLoop(details_)

this = public(@canvas, @mouse, @go, @stop);

%-----instance variables-----
canvas_ = Drawing(details_);
events_ = EyeEvents(details_);

go_ = 0;

    function c = canvas
        c = canvas_;
    end

    function m = eye
        m = mouse_;
    end

    function go(details)
        go_ = 1;
        interval = details.cal.interval;
        hitcount = 0;
        skipcount = 0;
        lastVBL = Screen('Flip', details.window);
        
        while(go_)
            events_.update();
            canvas_.draw();

            [VBL] = Screen('Flip', details.window);
            hitcount = hitcount + 1;
            
            %count the number of frames advanced and do the
            %appropriate number of canvas.update()s
            if lastVBL > 0
                frames = round((VBL - lastVBL) / interval);
                skipcount = skipcount + frames - 1;

                if frames > 60
                    error('mainLoop:drawingStuck', 'got stuck doing frame updates...');
                end
                for i = 1:frames
                    %may accumulate error if
                    %interval differs from the actual interval...
                    %but we're screwed in that case.
                    canvas_.update();
                end
            else
                %one update for the first time
                canvas_.update();
            end
            lastVBL = VBL;
        end
        disp(sprintf('hit %d frames, skipped %d', hitcount, skipcount));
    end

    function stop(x, y, t)
        go_ = 0;
    end

end