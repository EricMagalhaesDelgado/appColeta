function [appVersion, msgConsole] = appVersion(RootFolder)

    appVersion = struct('appColeta', '1.10', ...
                        'fiscaliza',  '',     ...
                        'anateldb',   '',     ...
                        'Matlab',     '',     ...
                        'Python',     '');
    
    % Python and fiscaliza
    Python = pyenv;
    appVersion.Python = struct('Version', Python.Version, 'Path', Python.Home);

    if isfile(Python.Executable)
        strPy = sprintf('Python v. %s\n%s', Python.Version, Python.Executable);
        
        try
            [~, fiscalizaVersion] = system(fullfile(Python.Home, 'Scripts', 'pip list | findstr fiscaliza'));
            if ~isempty(fiscalizaVersion); appVersion.fiscaliza = strtrim(extractAfter(fiscalizaVersion, 'fiscaliza'));
            end
        catch
        end
        
    else
        strPy = 'Python e a sua biblioteca "fiscaliza", a qual provê a integração appColeta/Fiscaliza, não instalados ou não mapeados.';
    end
    
    % anateldb
    global AnatelDB_info
    if isempty(AnatelDB_info)
        anateldb_Read(RootFolder)
    end
    appVersion.anateldb = AnatelDB_info;

    % Matlab    
    [MatlabVersion, ReleaseDate] = version;
    
    Products       = struct2table(ver);
    MatlabProducts = strjoin(string(Products.Name) + " v. " + string(Products.Version), ', ');

    appVersion.Matlab = struct('Version',  sprintf('%s (Release date: %s)', MatlabVersion, ReleaseDate), ...
                               'Products', MatlabProducts,                                               ...
                               'Path',     matlabroot);
    
    % Console message (executable version)
    msgConsole = sprintf('appColeta v. %s\n%s\n\nMatlab v. %s\n%s\n%s\n\n%s\n\n', ...
                         appVersion.appColeta, RootFolder, appVersion.Matlab.Version, appVersion.Matlab.Products, appVersion.Matlab.Path, strPy);
    
end