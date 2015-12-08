//
//  CCOLUtility.h
//  ColaLib
//
//  Created by Chris on 03/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLUtility_h
#define CCOLUtility_h

#include <AudioToolbox/AudioToolbox.h>
#import "Endian.h"

#include <string>
#include <cstdlib>   // for rand()

void gen_random(char *s, const int len) {
    static const char alphanum[] =
    "0123456789"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "abcdefghijklmnopqrstuvwxyz";
    
    for (int i = 0; i < len; ++i) {
        s[i] = alphanum[rand() % (sizeof(alphanum) - 1)];
    }
    
    s[len] = 0;
}


static void checkError(OSStatus error, const char *operation)
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

static OSType fourCharCode(NSString *string) {
    unsigned int fourCharCode;
    
    const char *bytes = (char*)[[string dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    *((char *) &fourCharCode + 0) = *(bytes + 0);
    *((char *) &fourCharCode + 1) = *(bytes + 1);
    *((char *) &fourCharCode + 2) = *(bytes + 2);
    *((char *) &fourCharCode + 3) = *(bytes + 3);
    
    return EndianU32_NtoB(fourCharCode);
}

#endif /* CCOLUtility_h */
