//
//  BuildView.h
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ComponentDescription.h"
#import "ConnectorView.h"

#import <UIKit/UIKit.h>

@interface BuildViewCellPath : NSObject
-(instancetype)initWithColumn:(NSUInteger)column Row:(NSUInteger)row;
@property (readonly) NSUInteger column;
@property (readonly) NSUInteger row;
@end

@interface BuildViewCable : NSObject
-(instancetype)initWithPoint:(CGPoint)point1 andPoint:(CGPoint)point2;
@property (nonatomic) CGPoint point1;
@property (nonatomic) CGPoint point2;
@property (nonatomic, strong) UIColor *colour;
@end

@interface BuildView : UIScrollView <UIScrollViewDelegate, ConnectorViewDelegate>

@property (nonatomic, strong) NSSet *highlightedCellSet;
@property (readonly, strong) ConnectorView *draggingConnector;

@property (readonly) CGSize cellSize;
@property (readonly) CGFloat headerHeight;
@property (readonly) NSUInteger rows;
@property (readonly) NSUInteger columns;

@property (readonly, strong) NSMutableArray *cables;

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point;
-(NSSet*)cellPathsForComponentOfWidth:(NSUInteger)width height:(NSUInteger)height center:(CGPoint)center;
-(UIView*)addViewForComponent:(ComponentDescription*)componentDescription atPoint:(CGPoint)point;
-(CGRect)rectForCellSet:(NSSet*)cellSet;

@end
