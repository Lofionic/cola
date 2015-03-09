//
//  BuildView.h
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ComponentDescription.h"
#import <UIKit/UIKit.h>

@interface BuildViewCellPath : NSObject

-(instancetype)initWithColumn:(NSUInteger)column Row:(NSUInteger)row;

@property (nonatomic) NSUInteger column;
@property (nonatomic) NSUInteger row;

@end

@interface BuildView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSSet *highlightedCellSet;

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point;
-(NSSet*)cellPathsForComponentOfWidth:(NSUInteger)width height:(NSUInteger)height center:(CGPoint)center;
-(UIView*)addViewForComponent:(ComponentDescription*)componentDescription atPoint:(CGPoint)point;

@end
