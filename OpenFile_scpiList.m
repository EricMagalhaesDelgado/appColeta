function [scpiList, msg] = OpenFile_scpiList(FilePath, RootFolder)

    scpiList = [];
    msg = '';

    try
        fileList = jsondecode(fileread(FilePath));
        if ~isempty(fileList)
            for ii = 1:numel(fileList)
                fileList(ii).Parameters = jsonencode(fileList(ii).Parameters);
            end

            scpiList     = struct2table(fileList, 'AsArray', true);
            scpiList.idx = (1:numel(fileList))';
            scpiList     = movevars(scpiList, 'idx', 'Before', 1);

            if strcmp(FilePath, fullfile(RootFolder, 'Settings', 'scpiList.json'))
                idx = find(scpiList.Family == "Receptor");
                if ~isempty(idx)
                    if ~any(scpiList.Enable(idx))
                        scpiList.Enable(idx(1)) = 1;
                        msg = sprintf('Como o arquivo "scpiList.json" não possuía registro de um receptor com o estado "ON", ativou-se um dos seus registros.');
                    end
                else
                    scpiList(end+1,:) = {numel(fileList)+1, 'Receptor', 'Tektronix SA2500', 'SA2500', 'TCPIP Socket', '{"IP":"127.0.0.1","Port":"34835","Timeout":5}', 'Modo servidor/cliente. Loopback (127.0.0.1).', 1, ''};
                    msg = sprintf('Como o arquivo "scpiList.json" não possuía registro de um receptor, criou-se o registro do instrumento virtual da Tektronix, o SA2500, cujo uso depende de prévia instalação do <i>app</i> "SA2500PC".');
                end
            end
        end        
    
    catch ME
        msg = getReport(ME);

        if strcmp(FilePath, fullfile(RootFolder, 'Settings', 'scpiList.json'))
            scpiList = table('Size', [0, 9],                                                                                 ...
                              'VariableTypes', {'double', 'cell', 'cell', 'cell', 'cell', 'cell', 'cell', 'double', 'cell'}, ...
                              'VariableNames', {'idx', 'Family', 'Name', 'Tag', 'Type', 'Parameters', 'Description', 'Enable', 'LOG'});

            scpiList(end+1,:) = {1, 'Receptor', 'Tektronix SA2500', 'SA2500', 'TCPIP Socket', '{"IP":"127.0.0.1","Port":"34835","Timeout":5}', 'Modo servidor/cliente. Loopback (127.0.0.1).', 1, ''};

            msg = sprintf('Como o arquivo <b>scpiList.json</b> está corrompido, criou-se o registro do instrumento virtual da Tektronix, o SA2500, cujo uso depende de prévia instalação do <i>app</i> "SA2500PC".\n\n%s', msg);
        end
    end

end