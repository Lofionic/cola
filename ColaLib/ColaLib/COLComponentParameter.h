//
//  COLComponentParamater.h
//  ColaLib
//
//  Created by Chris on 23/02/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COLComponentParameter : NSObject

@property (nonatomic, strong) NSString *name;

-(void)setTo:(float)newValue;
-(void)engineDidRender;
-(float)valueAtDelta:(float)delta;

@end
