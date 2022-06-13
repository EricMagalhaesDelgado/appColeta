function [udpPortArray, ind] = Connection_udpSockets(udpPortArray, Port, Timeout)

    ind = [];
    for ii = 1:numel(udpPortArray)
        if udpPortArray{ii}.LocalPort == Port
            ind = ii;
            break
        end
    end
    
    if isempty(ind)
        ind = numel(udpPortArray)+1;
        udpPortArray(ind) = {udpport('datagram', 'IPV4', 'LocalPort', Port, 'ByteOrder', 'big-endian', 'Timeout', Timeout)};
    end

end