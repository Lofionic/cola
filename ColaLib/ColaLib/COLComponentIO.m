//
//  COLComponentIO.m
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLComponentIO.h"
#import "COLComponent.h"

@interface COLComponentIO()

@property (nonatomic) kComponentIOType      type;
@property (nonatomic, weak) COLComponent    *component;
@property (nonatomic, strong) NSString      *name;

@end

@implementation COLComponentIO

-(instancetype)initWithComponent:(COLComponent*)component ofType:(kComponentIOType)type withName:(NSString*)name {
    if (self = [super init]) {
        self.component = component;
        self.type = type;
        self.name = name;
    }
    return self;
}

-(BOOL)isConnected {
    return self.connectedTo != nil;
}

-(BOOL)disconnect {
    return NO;
}

-(NSString*)nameWithComponent {
    if (self.component) {
        return [NSString stringWithFormat:@"%@:%@", [self.component name], _name];
    } else {
        return _name;
    }
}
@end
