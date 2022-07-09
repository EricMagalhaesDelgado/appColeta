function LOG = connect_RFeye(IP, webPass)

    webLogin = 'admin';
    LOG = struct('cgi',      struct('versions', '', 'ifconfig', '', 'apps', '', 'status',  '', 'error', ''), ...
                 'hostname', struct('cgi_versions', '', 'cgi_unitname', ''), ...
                 'gps',      struct('Latitude', -1, 'Longitude', -1));
    
    % WEB (cgi-bin)    
    try
        versions = webread(sprintf('http://%s/cgi-bin/versions.cgi', IP), weboptions('Username', webLogin, 'Password', webPass));
        
        LOG.cgi.versions = jsonencode(versions, "PrettyPrint", true);
        LOG.hostname.cgi_versions = lower(char(regexpi(versions.SoftwareComponents.Kernel, 'rfeye[0-9]{6}', 'match')));
    catch ME
        LOG.cgi.error.versions = ME.identifier;
    end

    try
        LOG.cgi.ifconfig = webread(sprintf('http://%s/cgi-bin/ifconfig.cgi', IP), weboptions('Username', webLogin, 'Password', webPass));
    catch ME
        LOG.cgi.error.ifconfig = ME.identifier;
    end

    try
        LOG.cgi.apps = jsonencode(webread(sprintf('http://%s/cgi-bin/apps_list.cgi', IP), weboptions('Username', webLogin, 'Password', webPass)), "PrettyPrint", true);
    catch ME
        LOG.cgi.error.apps = ME.identifier;
    end
    
    try
        status = webread(sprintf('http://%s/cgi-bin/status.cgi', IP), weboptions('Username', webLogin, 'Password', webPass));
        gps    = strsplit(status.GPS);
        LOG.cgi.status = jsonencode(status, "PrettyPrint", true);
        LOG.gps = struct('Latitude',  str2double(gps{6})/1e+6, ...
                         'Longitude', str2double(gps{7})/1e+6);
    catch ME
        LOG.cgi.error.status = ME.identifier;
    end
    
    try
        LOG.hostname.cgi_unitname = lower(char(regexpi(webread(sprintf('http://%s/cgi-bin/unitname.cgi', IP), weboptions('Username', webLogin, 'Password', webPass)), 'rfeye[0-9]{6}', 'match')));
    catch
    end
    
end