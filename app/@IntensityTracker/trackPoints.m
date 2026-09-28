function trackPoints(obj)

% Use "point-based" tracking to extract mean intensity values 
% about tracked points in the specified region(s) of interest.

% Display progress bar and/or video player, if requested
[progress,player] = obj.parseDisplay(obj.DisplayMode);
if isempty(player)
    showPlayer = false;
else
    showPlayer = true;
    marked = insertShape(obj.cframe1,"rectangle",obj.region,Color="white");
    player(marked)
end

% Open video writer, if requested
if isempty(obj.VideoWriter)
    saveVideo = false;
else
    saveVideo = true;
    open(obj.VideoWriter)
end

% Setup and initialize point tracker
tracker = vision.PointTracker(MaxBidirectionalError=1);
initialize(tracker,obj.points1,obj.cframe1);

% Display regions with color coded points
nReg = size(obj.region,1);  % number of regions with points
rnum = (1:nReg)';           % region numbers
rid = obj.pointIds;         % region IDs for each point
rval = ismember(rnum,rid);  % regions with valid points
if (nReg > 7)
    cmap = turbo(nReg);
else
    cmap = lines(nReg);
end
[h,w] = size(obj.cframe1,1:2); % frame size: [numrows numcols]
roi = obj.region;

% Process Video
k = 1;
obj.Video.CurrentTime = obj.InitialTime; % ensure video is reset
readFrame(obj.Video); % and advance video time
tDuration = obj.FinalTime - obj.InitialTime;
while hasFrame(obj.Video) && (obj.Video.CurrentTime <= obj.FinalTime)
    k = k + 1;
    progress.Value = (obj.Video.CurrentTime - obj.InitialTime)/tDuration;

    % Update cframe and iframe
    obj.time(k) = obj.Video.CurrentTime;
    frame = readFrame(obj.Video);
    [obj.cframe,obj.iframe] = fta.cropFrame(frame);
    [pts,pval] = tracker(obj.cframe);

    if all(~pval)
        msg = ["All valid point tracks have been lost. Verify regions " + ...
            "of interest have not gone off frame or become obstructed."; ...
            "To prevent early termination, consider adding more " + ...
            "points and/or enabling automatic point re-initialization."];

    else
        msg = [];
        rval = ismember(rnum,rid(pval)); % regions with valid points
        if (nnz(pval) > 1)
            % Update region by enclosing all valid points
            roi(rval,1) = grpstats(pts(pval,1),rid(pval),@(x)min(x,[],1));
            roi(rval,2) = grpstats(pts(pval,2),rid(pval),@(x)min(x,[],1));
            roi(rval,3) = grpstats(pts(pval,1),rid(pval),@(x)max(x,[],1)) - roi(rval,1);
            roi(rval,4) = grpstats(pts(pval,2),rid(pval),@(x)max(x,[],1)) - roi(rval,2);

        else
            % Use W/H from previous step and ensure still in frame
            roi(rval,1) = pts(pval,1) - roi(rval,3)/2;
            roi(rval,2) = pts(pval,2) - roi(rval,4)/2;
            roi(rval,1:2) = min(roi(rval,1:2)+0.5,[w h]-roi(rval,3:4));
            roi(rval,1:2) = max(roi(rval,1:2),[0.5 0.5]); % ensure roi within frame
        end

        if obj.AutoReInit
            if any(~pval)
                idx = (obj.points(:,1)>w-0.5) | (obj.points(:,2)>h-0.5) ...
                    | any(obj.points<0.5,2) | any(~isfinite(obj.points),2);
                pval(idx) = false; % ensure previous "valid" points are still valid
                obj.points = fta.initPoints(obj.cframe,roi,rid, ...
                    points=obj.points, validity=pval, Detector=obj.Detector);
                pval(:) = true; % all points are now valid
                rval = ismember(rnum,rid); % regions with valid points
                release(tracker)
                initialize(tracker,obj.points,obj.cframe)
            end
        end
    end

    if ~isempty(msg)
        k = k - 1;
        if (k == 1)
            msg = [msg(1); ""; msg(2); "";
                "There are no valid tracks/regions available for analysis."];
            if isa(obj.DisplayMode,"matlab.ui.Figure")
                uialert(obj.DisplayMode,msg,"Tracking Stopped",Icon="error");
            else
                warning(join(msg))
            end

        else
            msg = [msg(1); ""; "Elapsed Time = " ...
                + (obj.Video.CurrentTime-obj.time(1)) + " seconds"; ...
                "Video Time = " + obj.Video.CurrentTime + " seconds"; ""; msg(2); ""; ...
                "Previous valid tracks/regions will be used for analysis."];
            if isa(obj.DisplayMode,"matlab.ui.Figure")
                uialert(obj.DisplayMode,msg,"Tracking Stopped",Icon="warning");
            else
                warning(join(msg))
            end
        end
        break
    end

    % Update intensity values
    obj.points = pts;
    obj.points(~pval,:) = NaN; % ignore non-valid points
    obj.Ipoints(k,:) = fta.imhoodstat(obj.iframe,obj.points,obj.PixelHood,@mean);

    % Mark frame for player or writer, if needed
    if (showPlayer || saveVideo)
        % Create false color green overlay
        marked = cat(3, ...
            obj.cframe(:,:,1) - obj.iframe*0.666, ... % Red
            obj.cframe(:,:,2) + obj.iframe*0.333, ... % Green
            obj.cframe(:,:,3) - obj.iframe*0.666);    % Blue
        marked = insertMarker(marked, ...
            obj.points(pval,:),"+", Color=255*cmap(rid(pval),:));
        marked = insertObjectAnnotation(marked, ...
            "rectangle",roi(rval,:),rnum(rval), Color="white");
    end
    if showPlayer
        player(marked)
    end
    if saveVideo
        writeVideo(obj.VideoWriter,marked)
    end

    % Check if user closed video player
    if (showPlayer && ~isOpen(player))
        showPlayer = false;
        if isa(obj.DisplayMode,"matlab.ui.Figure")
            msg = "Video player has been closed. Press 'Continue' " + ...
                "to process video to completion in the background " + ...
                "or 'Stop' to end video processing at this time.";
            selection = uiconfirm(obj.DisplayMode,msg,"Video Player Closed", ...
                Options=["Continue" "Stop"], DefaultOption=2);
            if (selection == "Stop")
                break
            end
        else
            break
        end
    end
end

% Extract up to last good frame
obj.time = obj.time(1:k);
obj.Ipoints = obj.Ipoints(1:k,:); % frames x regions
obj.region = roi;

% Extract region intensities (frames x regions)
pval = all(~isnan(obj.Ipoints));
if (nnz(pval) == 1)
    obj.Iregion = obj.Ipoints(:,pval);
else
    % Transpose back and forth to use grpstats
    obj.Iregion = grpstats(obj.Ipoints(:,pval)',rid(pval),"mean")';
end

% Clean-Up
if ~isempty(player)
    release(player)
    delete(player)
end
if saveVideo
    close(obj.VideoWriter)
end
if isa(obj.DisplayMode,"matlab.ui.Figure")
    close(progress)
end

end

% Copyright 2023 The MathWorks, Inc.