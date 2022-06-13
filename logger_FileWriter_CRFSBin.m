function logger_FileWriter_CRFSBin(datatype, fileID, opt)

    switch datatype
        case 21; udpLogger_Write_DataType21(fileID, opt)
        case 40; udpLogger_Write_DataType40(fileID, opt)
    end

end

function udpLogger_Write_DataType21(fileID, opt)

    Node     = [opt{1} zeros(1, 16-numel(opt{1}))];
    unitInfo = opt{2};
    method   = opt{3};
    
    if mod(length(unitInfo), 4)
        unitInfo = [unitInfo zeros(1, 4-mod(length(unitInfo), 4))];
    end
    unitInfoLength = length(unitInfo);
    
    if mod(length(method), 4)
        method = [method zeros(1, 4-mod(length(method), 4))];
    end    
    methodLength = length(method);
    
    FileNumber = 0;
    BytesBlock = 28 + unitInfoLength + methodLength;
    
    udpLogger_Write_BlockHeader(fileID, 0, BytesBlock, 21);
    
    fwrite(fileID, Node,           'char*1');
    fwrite(fileID, unitInfoLength, 'uint32');
    fwrite(fileID, unitInfo,       'char*1');
    fwrite(fileID, methodLength,   'uint32');
    fwrite(fileID, method,         'char*1');
    fwrite(fileID, FileNumber,     'uint32');
    
    udpLogger_Write_BlockTrailer(fileID, BytesBlock)
    
end

function udpLogger_Write_DataType40(fileID, opt)

    Time      = opt{1};
    Latitude  = opt{2};
    Longitude = opt{3};
    Altitude  = opt{4};

    udpLogger_Write_BlockHeader(fileID, 1, 40, 40);

    fwrite(fileID,   day(Time));
    fwrite(fileID, month(Time));
    fwrite(fileID,  year(Time)-2000);
    fwrite(fileID, 0);
    
    fwrite(fileID,   hour(Time));
    fwrite(fileID, minute(Time));
    fwrite(fileID, second(Time));
    fwrite(fileID, 0);
    
    fwrite(fileID, 0, 'uint32');
    
    fwrite(fileID,   day(Time));
    fwrite(fileID, month(Time));
    fwrite(fileID,  year(Time)-2000);
    fwrite(fileID, 0);
    
    fwrite(fileID,   hour(Time));
    fwrite(fileID, minute(Time));
    fwrite(fileID, second(Time));
    fwrite(fileID, 0);
        
    fwrite(fileID, 1);                          % Status
    fwrite(fileID, 0);                          % Satellites in view
    fwrite(fileID, 0, 'uint16');                % Heading

    fwrite(fileID, Latitude  .* 1e+6, 'int32'); % Latitude
    fwrite(fileID, Longitude .* 1e+6, 'int32'); % Longitude
    
    fwrite(fileID, 0, 'uint32');                % Speed
    fwrite(fileID, Altitude .* 1000, 'uint32'); % Altitude
        
    udpLogger_Write_BlockTrailer(fileID, 40)
    
end

function udpLogger_Write_BlockHeader(fileID, ThreadID, BytesBlock, DataType)
    
    fwrite(fileID, [ThreadID, BytesBlock], 'uint32');
    fwrite(fileID, DataType, 'int32');
    
end

function udpLogger_Write_BlockTrailer(fileID, BytesBlock)
    
    fseek(fileID, -(12+BytesBlock), 'cof');
    CheckSumAdd = fread(fileID, (12+BytesBlock), 'uint8');
    CheckSumAdd = uint32(sum(CheckSumAdd));
    fseek(fileID, 0, 'cof');
    
    fwrite(fileID, CheckSumAdd, 'uint32');
    fwrite(fileID, 'UUUU', 'char*1');
    
end