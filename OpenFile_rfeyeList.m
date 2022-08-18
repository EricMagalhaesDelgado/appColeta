function [rfeyeList, msg] = OpenFile_rfeyeList(FilePath)

    rfeyeList = [];
    msg = '';

    try
        load(FilePath, '-mat', 'rfeyeList')

        if isempty(rfeyeList)
            error('')
        end

    catch ME
        msg = sprintf('O arquivo <b>rfeyeList.cfg</b> está corrompido.\n\n%s', getReport(ME));
    end
    
end