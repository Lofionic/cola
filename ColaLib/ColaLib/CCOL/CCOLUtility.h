//
//  CCOLUtility.h
//  ColaLib
//
//  Created by Chris on 03/11/2015.
//  Copyright © 2015 Chris Rivers. All rights reserved.
//

#ifndef CCOLUtility_h
#define CCOLUtility_h

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

#endif /* CCOLUtility_h */
