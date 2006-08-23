function initializer = GetEyelink(varargin)
%
%Produces an intialization function for use with REQUIRE, which:
%
%Connects to the Eyelink system, running the
%calibration and choosing an file name; cleans up the connection at close.
%
%Input structure fields:
%   window - the PTB window number
%   rect - the window rect
%   edfname - the file name to use -- use empty string for no file,
%                otherwise it will pick a name
%
%Output structure fields:
%   el - the eyelink info structure
%   edfname - the EDF file name
%   localname - full path to where the EDF file is downloaded locally
%   dummy - whether the eyelink was opened in dummy mode

FILE_CANT_OPEN = -1;

%build the initializer, and curry it with given args.
initializer = joinResource(@connect, @initDefaults, @doSetup, @openEDF);
initializer = setnargout(2, currynamedargs(initializer, varargin{:}));

%sub-initializers:

    %open/close the eyelink connection
    function [release, details] = connect(details)
        %connect to the eyelink machine.
        try
            status = Eyelink('Initialize');
        catch
            warning('Using eyelink in dummy mode')
            status = Eyelink('InitializeDummy');
        end
        
        if status < 0
            error('getEyelink:initFailed',...
                'Initialization status %d', status);
        end
        
        [release, details] = deal(@close, details);
        
        function close
            Eyelink('Shutdown'); %no output argument
        end
    end


    %initialize eyelink defaults. Requires the 'window' field from getScreen.
    %output fields - 'dummy' if we are in dummy mode
    function [release, details] = initDefaults(details)
        el = EyelinkInitDefaults(details.window);
        details.el = el;
        
        conn = Eyelink('IsConnected');
        switch conn
            case el.connected
                details.dummy = 0;
            case el.dummyconnected
                details.dummy = 1;
            otherwise
                error('getEyelink:notConnected', 'not connected (%d)', conn);
        end
        
        [release, details] = deal(@noop, details);
        
        function noop
            %While EyelinkInitDefaults changes the eyelink's screen
            %resolution settings, there is no way to tell what the setings
            %were before, so there is nothing to be done for cleanup.
        end
    end


    %do the tracker setup. Requires the 'el' field from initDefaults as
    %well as the 'rect' field from getScreen.
    function [release, details] = doSetup(details)
        
        %set and record as many settings as possible
        eyelinkSettings = setupEyelink(details.rect);
        details.eyelinkSettings = eyelinkSettings;
        
        if ~details.dummy
            disp('Do tracker setup now');
            status = EyelinkDoTrackerSetup(details.el, details.el.ENTER_KEY);
            if status < 0
                error('getEyelink:TrackerSetupFailed', 'Eyelink setup failed.');
            end
        end
        
        [release, details] = deal(@noop, details);
        
        function noop
            %nothing to undo
        end
    end

    %open the eyelink data file on the eyelink machine
    %input field: dummy: skips a file check in dumy mode
    %output field: edfFilename = the name of the EDF file created
    function [release, details] = openEDF(details)
        e = env;

        if ~isfield(details, 'edfname')
            %pick some kind of unique filename by combining a prefix with
            %a 7-letter encoding of the date and time

            pause(1); % to make it likely that we get a unique filename, hah!
            % oh, why is the eyelink so dumb?
            details.edfname = ['z' clock2filename(clock) '.edf'];
        end

        if ~isempty(details.edfname)
            %make a note of where we will find the file locally
            details.localname = fullfile(e.eyedir, details.edfname);

            %the eyelink has no way directly to check that the filename is
            %valid or non-existing... so we must assert that we can't open the
            %file yet.
            tmp = tempname();
            status = Eyelink('ReceiveFile',details.edfname,tmp);
            if (~details.dummy) && (status ~= FILE_CANT_OPEN)
                error('Problem generating filename (expected status %d, got %d)',...
                    details.el.FILE_CANT_OPEN, status);
            end

            %destructive step: open the file
            %FIXME - what data can I get out of here?
            Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
            status = Eyelink('OpenFile', details.edfname);
            if (status < 0)
                error('getEyelink:fileOpenError', ...
                    'status %d opening eyelink file %s', status, edfname);
            end
        else
            %not recording -- don't leave some random previous file open on
            %eyelink
            status = Eyelink('CloseFile');
            if status ~= 0
                error('GetEyelink:couldNotClose', 'status %d closing EDF file', status);
            end
            details.localname = '';
        end

        %when we are done with the file, download it
        release = @downloadFile;

        function downloadFile
            %if we were recording to a file, download it
            if ~isempty(details.edfname)
                %try both in any case
                status = Eyelink('CloseFile');
                if Eyelink('IsConnected') ~= details.el.dummyconnected
                    fsize = Eyelink('ReceiveFile', edfname, localname);

                    if (fsize < 1 || status < 0)
                        error('getEyeink:fileTransferError', ...
                            'File %s empty or not transferred (close status: %d, receive: %d)',...
                            edfname, status, fsize);
                    end
                end
            end
        end
        
    end

end