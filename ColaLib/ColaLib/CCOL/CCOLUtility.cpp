//
//  CCOLUtility.cpp
//  ColaLib
//
//  Created by Chris on 18/03/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#include "CCOLUtility.hpp"

void checkError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(errorString, "%d", (int)error);
    
    fprintf(stderr, "CCOLAudioEngine: Error: %s (%s)\n", operation, errorString);
    
    exit(1);
}