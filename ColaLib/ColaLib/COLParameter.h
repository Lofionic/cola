//
//  COLParameter.h
//  ColaLib
//
//  Created by Chris on 01/04/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import <Foundation/Foundation.h>

@class COLComponent;
@interface COLParameter : NSObject

@property (nonatomic, weak) COLComponent *component;
@property (nonatomic, strong) NSString *name;

-(instancetype)initWithComponent:(COLComponent*)component withName:(NSString*)name;
-(void)engineDidRender;

@end
