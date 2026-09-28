function trackRegions(obj)

% Use "region-based" tracking to extract mean intensity values from a
% grid of regions spread across the full frame. (Uses point tracking to
% perform image registration, which then allows for block processing.)

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

% Initialize grid region intensity values
[h,w] = size(obj.cframe1,1:2); % frame size: [numrows numcols]
nRows = numel(unique(obj.region(:,2))); % number of grid rows
nCols = numel(unique(obj.region(:,1))); % number of grid columns
rval = true(nRows*nCols,1); % all regions valid
OV = imref2d([h w]);  % registered output view

tDuration = obj.FinalTime - obj.InitialTime;
nFrames = ceil(tDuration*ceil(obj.Video.FrameRate));
Igrid = NaN([nRows nCols nFrames],"single");
Igrid(:,:,1) = imresize( obj.iframe, [nRows nCols], "box" );

% Process Video
k = 1;
obj.Video.CurrentTime = obj.InitialTime; % ensure video is reset
readFrame(obj.Video); % and advance video time
while hasFrame(obj.Video) && (obj.Video.CurrentTime <= obj.FinalTime)
    k = k + 1;
    progress.Value = (obj.Video.CurrentTime - obj.InitialTime)/tDuration;

    % Update cframe and iframe
    obj.time(k) = obj.Video.CurrentTime;
    frame = readFrame(obj.Video);
    [obj.cframe,obj.iframe] = fta.cropFrame(frame);
    [obj.points,pval] = tracker(obj.cframe);

    % Update point intensity values
    obj.points(~pval,:) = NaN; % ignore non-valid points
    obj.Ipoints(k,:) = fta.imhoodstat(obj.iframe,obj.points,obj.PixelHood,@mean);

    if all(~pval)
        msg = ["All valid point tracks have been lost. Verify regions " + ...
            "of interest have not gone off frame or become obstructed."; ...
            "To prevent early termination, consider adding more " + ...
            "points and/or enabling automatic point re-initialization."];

    else
        msg = [];
        % Use point tracking to compute affine transform:
        % * point registration faster than auto registration (imregtform)
        % * "affine" transform faster than "polynomial" (order 2)
        try
            tform  = fitgeotform2d(obj.points(pval,:),obj.points1(pval,:),"affine");
            obj.cframe = imwarp(obj.cframe, tform, OutputView=OV);
            obj.iframe = imwarp(obj.iframe, tform, OutputView=OV);
            I = single(obj.iframe); % NaN not available for uint8
            I(all(obj.cframe==0,3)) = NaN; % ignore black padding due to frame warping
            Igrid(:,:,k) = imresize( I, [nRows nCols], "box" );
            rval = (rval & reshape(~isnan(Igrid(:,:,k)),nRows*nCols,1));
            if all(~rval,"all")
                msg = ["All regions have become invalid due to frame warping."; ...
                    "To prevent early termination, consider adding more grid regions."];
            end

        catch ME
            msg = ["Frame registration has failed: " + ME.message;
                "To prevent early termination, consider adding more points."];
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

    if showPlayer
        % Create false color green overlay
        marked = cat(3, ...
            obj.cframe(:,:,1) - obj.iframe*0.666, ... % Red
            obj.cframe(:,:,2) + obj.iframe*0.333, ... % Green
            obj.cframe(:,:,3) - obj.iframe*0.666);    % Blue
        marked = insertShape(marked, "rectangle", ...
            obj.region(rval,:), Color="white");
        player(marked)
    end
    if saveVideo
        writeVideo(obj.VideoWriter,vertcat(obj.cframe,repmat(obj.iframe,1,1,3)))
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
obj.Ipoints = obj.Ipoints(1:k,:); % frames x points
obj.Iregion = reshape(Igrid(:,:,1:k),nRows*nCols,k)'; % frames x regions

% Update with registered points
pval = all(~isnan(obj.Ipoints));
if (k > 1)
    [x,y] = transformPointsForward(tform, ...
        obj.points(pval,1), obj.points(pval,2));
    obj.points(pval,:) = [x y];
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