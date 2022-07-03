function timeInfo = task_timeIssue(Type, gpsRevisitTime, Task, Duration_sec)

    if ~strcmp(Type, 'Monitoração espectral - Drive-test')
        array = [gpsRevisitTime, [Task.Band.RevisitTime]];
        timeInfo.RevisitTime = min(array(2:end));
        
        if gpsRevisitTime < timeInfo.RevisitTime
            gpsRevisitTime = timeInfo.RevisitTime;
        end
        
        for ii = numel(Task.Band):-1:0
            if ii
                timeInfo.RevisitFactor(ii+1) = fix(Task.Band(ii).RevisitTime ./ timeInfo.RevisitTime);
            else
                timeInfo.RevisitFactor(ii+1) = fix(gpsRevisitTime ./ timeInfo.RevisitTime);
            end
            timeInfo.EstimatedLoops(ii+1) = ceil(Duration_sec/(timeInfo.RevisitTime * timeInfo.RevisitFactor(ii+1)));
        end
    
    else
        timeInfo.RevisitTime    = min([Task.Band.RevisitTime]);
        timeInfo.RevisitFactor  = ones(1, numel(Task.Band)+1);
        timeInfo.EstimatedLoops = ones(1, numel(Task.Band)+1) .* ceil(Duration_sec/timeInfo.RevisitTime);
    end

end