//
//  COLIOPort.h
//  ColaLib
//
//  Created by Chris on 13/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>

@class COLComponent;
typedef NS_ENUM(NSUInteger, kComponentIOType) {
    kComponentIOTypeAudio,
    kComponentIOTypeControl,
    kComponentIOType1VOct,
    kComponentIOTypeGate
};

@interface COLComponentIO : NSObject

@property (readonly) kComponentIOType           type;
@property (readonly, weak) COLComponent         *component;
@property (readonly, strong) NSString           *name;
@property (nonatomic, weak) COLComponentIO       *connectedTo;

-(instancetype)initWithComponent:(COLComponent*)component ofType:(kComponentIOType)type withName:(NSString*)name;
-(BOOL)isConnected;
-(void)engineDidRender;

-(BOOL)disconnect;

@end
