//
//  COLIOPort.m
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentIO.h"

@interface COLComponentIO()

@property (nonatomic) kComponentIOType type;
@property (nonatomic, weak) COLComponent *component;

@end

@implementation COLComponentIO

-(instancetype)initWithComponent:(COLComponent*)component ofType:(kComponentIOType)type {
    if (self = [super init]) {
        self.component = component;
        self.type = type;
    }
    return self;
}

@end
