function outInfo = logger_DatagramRead(DataType, Datagram, opt)

    arguments
        DataType int32
        Datagram double
        opt      uint32 = []
    end

    switch DataType
        case 40;       outInfo = Fcn_GPSRead(Datagram);
        case 42;       outInfo = Fcn_TextRead(Datagram);
        case {67, 68}; outInfo = Fcn_SpectralRead(DataType, Datagram, opt);
    end

end

function GPS = Fcn_GPSRead(Datagram)

    Date_Day     = double(Datagram(33));
    Date_Month   = double(Datagram(34));
    Date_Year    = double(Datagram(35)) + 2000;

    Time_Hours   = double(Datagram(37));
    Time_Minutes = double(Datagram(38));
    Time_Seconds = double(Datagram(39));
    
    GPS.TimeStamp        = datestr(datetime([Date_Year, Date_Month, Date_Day, Time_Hours, Time_Minutes, Time_Seconds]), 'dd/mm/yyyy HH:MM:ss');
    GPS.Status           = Datagram(41);
%   GPS.SatellitesInView = Datagram(42);
%   GPS.Heading          = double(typecast(uint8(Datagram(43:44)), 'uint16')) / 100;
    GPS.Latitude         = double(typecast(uint8(Datagram(45:48)), 'int32' )) / 1e+6;
    GPS.Longitude        = double(typecast(uint8(Datagram(49:52)), 'int32' )) / 1e+6;
%   GPS.Speed            = double(typecast(uint8(Datagram(53:56)), 'uint32')) / 1000;
    GPS.Altitude         = double(typecast(uint8(Datagram(57:60)), 'uint32')) / 1000;
    
end

function outInfo = Fcn_TextRead(Datagram)

    Date_Day     = double(Datagram(21));
    Date_Month   = double(Datagram(22));
    Date_Year    = double(Datagram(23)) + 2000;

    Time_Hours   = double(Datagram(25));
    Time_Minutes = double(Datagram(26));
    Time_Seconds = double(Datagram(27));
    TimeStamp    = datestr(datetime([Date_Year, Date_Month, Date_Day, Time_Hours, Time_Minutes, Time_Seconds]), 'dd/mm/yyyy HH:MM:ss');

    Identifier     = deblank(char(Datagram(41:72)));
    FreeTextLength = double(typecast(uint8(Datagram(73:76)), 'uint32'));
    FreeText       = '';

    if FreeTextLength
        FreeText = deblank(char(Datagram(77:76+FreeTextLength)));
    end

    outInfo = {TimeStamp, Identifier, FreeText};

end


function outInfo = Fcn_SpectralRead(DataType, Datagram, ThreadID)

    Bin = struct('ThreadID',    ThreadID, ...
                 'Description', '', ...
                 'FreqStart',   [], ...
                 'FreqStop',    [], ...
                 'Resolution',  [], ...
                 'Operation',   '', ...
                 'LevelUnit',   '', ...
                 'DataPoints',  [], ...
                 'StepWidth',   [], ...
                 'REC',         []);
    
    DescriptionLength = double(typecast(uint8(Datagram(41:44)), 'uint32'));
    Bin.Description   = deblank(char(Datagram(45:45+DescriptionLength-1)));
    
    IntegerPart    = double(typecast(uint8(Datagram(45+DescriptionLength:46+DescriptionLength)), 'uint16'));
    DecimalPart    = double(typecast(uint8(Datagram(47+DescriptionLength:50+DescriptionLength)), 'int32'));
    Bin.FreqStart  = (IntegerPart + DecimalPart./1e+9) .* 1e+6;
    
    IntegerPart    = double(typecast(uint8(Datagram(51+DescriptionLength:52+DescriptionLength)), 'uint16'));
    DecimalPart    = double(typecast(uint8(Datagram(53+DescriptionLength:56+DescriptionLength)), 'int32'));
    Bin.FreqStop   = (IntegerPart + DecimalPart./1e+9) .* 1e+6;
    
    Bin.Resolution = double(typecast(uint8(Datagram(57+DescriptionLength:60+DescriptionLength)), 'uint32'));
    
    switch Datagram(74+DescriptionLength)
        case 0; Bin.Operation = 'Single Measurement';
        case 1; Bin.Operation = 'Mean';
        case 2; Bin.Operation = 'Peak';
        case 3; Bin.Operation = 'Minimum';
    end
    
    switch Datagram(75+DescriptionLength)
        case 0; Bin.LevelUnit = 'dBm';
        case 1; Bin.LevelUnit = 'dBµV/m';
    end
    
    OFFSET = double(typecast(uint8(Datagram(76+DescriptionLength)), 'int8'));
    NTUN   = typecast(uint8(Datagram(80+DescriptionLength:81+DescriptionLength)), 'uint16');
    NAGC   = typecast(uint8(Datagram(82+DescriptionLength:83+DescriptionLength)), 'uint16');

    switch DataType
        case 67
            Bin.DataPoints = double(typecast(uint8(Datagram(85+DescriptionLength:88+DescriptionLength)), 'uint32'));
            Bin.StepWidth  = (Bin.FreqStop-Bin.FreqStart)/(Bin.DataPoints-1);

            newArray = Datagram(89+DescriptionLength+4*NTUN+NAGC:89+DescriptionLength+4*NTUN+NAGC+Bin.DataPoints-1)./2 + OFFSET - 127.5;

        case 68
            NCDATA = double(typecast(uint8(Datagram(85+DescriptionLength:88+DescriptionLength)), 'uint32'));
            THRESH = double(typecast(uint8(Datagram(89+DescriptionLength:92+DescriptionLength)), 'int32'));
        
            Bin.DataPoints = double(typecast(uint8(Datagram(93+DescriptionLength:96+DescriptionLength)), 'uint32'));
            Bin.StepWidth  = (Bin.FreqStop-Bin.FreqStart)/(Bin.DataPoints-1);
        
            CompressedData = Datagram(97+DescriptionLength+4*NTUN+NAGC:97+DescriptionLength+4*NTUN+NAGC+NCDATA-1);
            TraceData      = 2*((THRESH-1)-(OFFSET-127.5))*ones(Bin.DataPoints, 1, 'single');
            
            kk = 0;
            ll = 0;
            while kk < numel(CompressedData)
                kk=kk+1;
                TraceValue = CompressedData(kk);
                
                if TraceValue == 255
                    kk=kk+1;
                    ll=ll+CompressedData(kk);
                else
                    ll=ll+1;
                    TraceData(ll,1) = TraceValue;
                end
            end
            
            newArray = single(TraceData)/2 + OFFSET - 127.5;
    end

    outInfo = {Bin, newArray};

end