function TaskEdit_File(taskList, RootFolder, Type)

    % taskList.json
    for ii = 1:numel(taskList)
        if taskList{ii}.Duration == inf
            taskList{ii}.Duration = 60;
        end

        if isfield(taskList{ii}.Band, 'instrStepWidth_Items')
            taskList{ii}.Band = rmfield(taskList{ii}.Band, {'instrStepWidth_Items',   'instrStepWidth',       ...
                                                            'instrDataPoints_Limits', 'instrDataPoints',      ...
                                                            'instrResolution_Items',  'instrResolution',      ...
                                                            'instrSelectivity',       'instrSensitivityMode', ...
                                                            'instrPreamp',            'instrAttMode',         ...
                                                            'instrAttFactor_Items',   'instrAttFactor',       ...
                                                            'instrDetector_Items',    'instrDetector',        ...
                                                            'instrLevelUnit',         'instrIntegrationTime', 'EditedFlag'});
        else
            taskList{ii}.Band = rmfield(taskList{ii}.Band,  'EditedFlag');
        end
    end
        
    switch Type
        case 'Full'
            % taskList.json
            filename2 = fullfile(RootFolder, 'Settings', 'taskList.json');

        case 'JustTask'
            filename2 = fullfile(RootFolder, sprintf('%s_taskList.json', datestr(now,'yymmdd_THHMMSS')));
    end
    
    if ~isempty(taskList)
        fileID2 = fopen(filename2, 'wt');
        fwrite(fileID2, jsonencode(taskList, 'PrettyPrint', true));
        fclose(fileID2);
    end
    
end