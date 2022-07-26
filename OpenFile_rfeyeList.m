function [rfeyeList, msg] = OpenFile_rfeyeList(FilePath)

    rfeyeList = [];
    msg = '';

    try
        load(FilePath, '-mat', 'rfeyeList')

        if isempty(rfeyeList)
            error('')
        end

    catch ME
        msg = sprintf('<b>O arquivo "rfeyeList.cfg" está corrompido.</b>\n\n%s', getReport(ME));
    end
    
end