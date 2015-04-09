//
//  BuildView.h
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "ConnectorView.h"
#import "ModuleView.h"

#import <UIKit/UIKit.h>

@interface BuildViewCellPath : NSObject
-(instancetype)initWithColumn:(NSUInteger)column Row:(NSUInteger)row;
@property (readonly) NSUInteger column;
@property (readonly) NSUInteger row;
@end

@class BuildView;
@interface BuildViewCable : NSObject
-(instancetype)initWithPoint:(CGPoint)point1 andPoint:(CGPoint)point2 inBuildView:(BuildView*)buildView;
-(void)updatePoints;

@property (nonatomic, weak) BuildView       *buildView;
@property (nonatomic, weak) ConnectorView   *connector1;
@property (nonatomic, weak) ConnectorView   *connector2;
@property (nonatomic) CGPoint point1;
@property (nonatomic) CGPoint point2;
@property (nonatomic, strong) UIColor *colour;
@end

@class BuildViewController;
@class ModuleDescription;
@interface BuildView : UIScrollView <UIScrollViewDelegate, ConnectorViewDelegate, ModuleViewDelegate>

@property (nonatomic, weak) BuildViewController *buildViewController;

@property (nonatomic, strong) NSSet *highlightedCellSet;
@property (readonly, strong) ConnectorView *draggingConnector;

@property (readonly) CGSize cellSize;
@property (readonly) CGFloat headerHeight;
@property (readonly) NSUInteger rows;
@property (readonly) NSUInteger columns;

@property CGFloat test;

@property (readonly, strong) NSMutableArray *cables;

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point;
-(NSSet*)cellPathsForModuleOfWidth:(NSUInteger)width center:(CGPoint)center occupied:(BOOL*)occupied;
-(UIView*)addViewForModule:(ModuleDescription*)moduleDescription atPoint:(CGPoint)point;
-(CGRect)rectForCellSet:(NSSet*)cellSet;

-(NSDictionary*)getPatchDictionary;

@end
