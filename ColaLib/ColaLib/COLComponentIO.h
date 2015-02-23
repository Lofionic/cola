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
    kComponentIOTypeControl
};

@interface COLComponentIO : NSObject

@property (readonly)            kComponentIOType type;
@property (readonly, weak)      COLComponent *component;
@property (nonatomic, weak) id  connectedTo;

-(instancetype)initWithComponent:(COLComponent*)component ofType:(kComponentIOType)type withName:(NSString*)name;
-(BOOL)isConnected;
-(NSString*)name;

@end
