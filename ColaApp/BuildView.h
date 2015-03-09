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

-(instancetype)initWithColumn:(NSInteger)column Row:(NSInteger)row;

@property (nonatomic) NSInteger column;
@property (nonatomic) NSInteger row;

@end

@interface BuildView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSSet *highlightedCellSet;

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point;
-(NSSet*)cellPathsForComponentOfWidth:(NSInteger)width height:(NSInteger)height center:(CGPoint)center;
-(UIView*)addViewForComponent:(ComponentDescription)componentDescription atPoint:(CGPoint)point;

@end
