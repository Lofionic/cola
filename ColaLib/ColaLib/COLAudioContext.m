//
//  COLAudioContext.m
//  ColaLib
//
//  Created by Chris on 17/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "COLAudioContext.h"
#import "COLComponentInput.h"

@interface COLAudioContext ()

@property (nonatomic, strong) NSArray *masterInputs;

@end

@implementation COLAudioContext

+ (instancetype) globalContext {
    static COLAudioContext *globalContext = nil;
    
    static dispatch_once_t contextOnceToken;
    dispatch_once(&contextOnceToken, ^{
        globalContext = [[self alloc] init];
        
        COLComponentInput *masterL = [[COLComponentInput alloc] initWithComponent:nil ofType:kComponentIOTypeAudio withName:@"Master L"];
        COLComponentInput *masterR = [[COLComponentInput alloc] initWithComponent:nil ofType:kComponentIOTypeAudio withName:@"Master R"];
        
        [globalContext setMasterInputs:@[masterL, masterR]];
    });
    return globalContext;    
}

- (COLComponentInput*)masterInputAtIndex:(NSInteger)index {
    if (index < [self.masterInputs count]) {
        return [self.masterInputs objectAtIndex:index];
    } else {
        return nil;
    }
}

@end
