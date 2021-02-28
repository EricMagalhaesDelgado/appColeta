import pyvisa as visa

import numpy as np
import time

def visaFunction(IP, Points, Samples):

    yTrace = np.zeros((Points, Samples), dtype=float)
    elapseTime = 0.0
    
    rm = visa.ResourceManager()
    Instrument = rm.open_resource('TCPIP0::' + IP + '::inst0::INSTR')
    
    Instrument.write((':INSTrument:SELect SAN;:FORMat:DATA REAL,32;:SENSe:SWEep:TIME:AUTO 1;'
                      ':INITiate:CONTinuous OFF;:SENSe:SWEep:POINTS ' + str(Points)))
   
    startTime = time.time()
    for ii in range (Samples):
        Instrument.write(':INITiate:IMMediate;*WAI');
        yTrace[:,ii] = Instrument.query_binary_values(':TRACe:DATA? TRACe1')
    
    elapseTime = time.time() - startTime
    
    Instrument.close()
    rm.close()
    
    return yTrace, elapseTime


