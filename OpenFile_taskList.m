function [taskList, msg] = OpenFile_taskList(FilePath, RootFolder)

    taskList = [];
    msg = '';

    try
        taskTemp = jsondecode(fileread(FilePath));
        for ii = 1:numel(taskTemp)
            taskList{ii} = taskTemp(ii);

            if isempty(taskList{ii}.Duration)
                taskList{ii}.Duration = inf;
            end

            if ~any([taskList{ii}.Band.Enable])
                taskList{ii}.Band(1).Enable = 1;
                msg = sprintf('Corrigida informação do arquivo com relação de tarefas, de forma que cada tarefa possua ao mesmo uma faixa de frequência com o estado "ON".');
            end
        end
    
    catch ME
        msg = getReport(ME);

        if strcmp(FilePath, fullfile(RootFolder, 'Settings', 'taskList.json'))
            msg = sprintf('Como o arquivo <b>taskList.json</b> está corrompido, criou-se o registro de uma tarefa.\n\n%s', msg);
            
            taskList = {struct('Name', 'appColeta HOM_1', 'BitsPerSample', 8, 'Duration', 600, ...
                               'Band', struct('ThreadID',         1,              ...
                                              'Description',      'Faixa 1 de 1', ...
                                              'FreqStart',        76000000,       ...
                                              'FreqStop',         108000000,      ...
                                              'StepWidth',        5000,           ...
                                              'Resolution',       30000,          ...
                                              'RFMode',           'Normal',       ...
                                              'TraceMode',        'ClearWrite',   ...
                                              'Detector',         'Sample',       ...
                                              'LevelUnit',        'dBm',          ...
                                              'RevisitTime',       0.1,           ...
                                              'IntegrationFactor', 1,             ...
                                              'Enable',            1))};
        end
    end

end