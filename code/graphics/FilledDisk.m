function this = FilledDisk(varargin)
%function this = FilledDisk(loc_, width_, color_)
%A graphics object that draws a disk at a specified location.
%
%loc_ : the coordinates (in degrees) of the center of the disk.
%radius_: the radius of the disk in degrees.
%color_: the color of the disk.
%
%See also Drawer, Drawing.

dotType = 1;
visible = 0;
loc = [0 0];
radius = [0 0];
color = [0 0 0];

varargin = assignments(varargin, 'loc', 'radius', 'color');
setLoc(loc);
persistent init__;
this = autoobject(varargin{:});

toPixels_ = [];

%----- methods -----

    function draw(window, next)
        try
            if visible
                l = e(loc, next);
                
                center = toPixels_(l);
                sz = norm(center - toPixels_(l + [radius;0]));
                if any(sz > 31)
                    Screen('gluDisk', window, color, center(1), center(2), sz);
                else
                    [src, dst] = Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    Screen('DrawDots', window, center, sz*2, color, [0 0], dotType);
                    Screen('BlendFunction', window, src, dst);
                end
            end
        catch
            rethrow(lasterror);
        end
    end

    function b = bounds
        disp = repmat(radius, 1, 2);
        center = loc;
        b = ([center - disp, center + disp]);
    end

    function [release, params] = init(params)
        toPixels_ = transformToPixels(params.cal);
        release = @noop;
    end

    function update(frames)
    end

    function v = getVisible
        v = visible;
    end

    function v = setVisible(v)
        visible = v;
    end

    function l = getLoc
        l = loc;
    end

    function l = setLoc(l)
        if isnumeric(l) && isvector(l)
            loc = l(:);
        else
            loc = l;
        end
    end

    function r = getRadius
        r = radius;
    end

    function r = setRadius(r)
        radius = r;
    end

    function c = getColor
        c = color;
    end

    function c = setColor(c)
        color = c;
    end

end
