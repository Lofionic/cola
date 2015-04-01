//
//  COLParameter.m
//  ColaLib
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import "COLParameter.h"

@implementation COLParameter

-(instancetype)initWithComponent:(COLComponent*)component withName:(NSString*)name {
    if (self = [super init]) {
        self.component = component;
        self.name = name;
    }
    return self;
}

-(void)engineDidRender {
    
}

@end
