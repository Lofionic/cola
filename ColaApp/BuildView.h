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

typedef enum {
    BuildViewCableBehaviourDrag,
    BuildViewCableBehaviourDraw
} BuildViewCableBehaviour;

@interface BuildViewCellPath : NSObject
-(instancetype)initWithColumn:(NSUInteger)column Row:(NSUInteger)row;
@property (readonly) NSUInteger column;
@property (readonly) NSUInteger row;
@end

@class BuildView;
@interface BuildViewCable : NSObject
-(instancetype)initWithPoint:(CGPoint)point1 andPoint:(CGPoint)point2 inBuildView:(BuildView*)buildView;
-(NSDictionary*)getDictionary;
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
@class MasterModuleView;
@interface BuildView : UIView <ConnectorViewDelegate, ModuleViewDelegate, UIScrollViewDelegate>

-(instancetype)initWithScrollView:(UIScrollView *)scrollView;

@property (nonatomic, weak) BuildViewController *buildViewController;

@property (nonatomic, strong) NSSet *highlightedCellSet;
@property (readonly, strong) ConnectorView *draggingConnector;

@property (readonly) NSUInteger rows;
@property (readonly) NSUInteger columns;

@property (nonatomic) BuildViewCableBehaviour cableBehaviour;

@property CGFloat test;

@property (readonly, strong) NSMutableArray *cables;

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point;
-(NSSet*)cellPathsForModuleOfWidth:(NSUInteger)width center:(CGPoint)center occupied:(BOOL*)occupied;
-(ModuleView*)addViewForModule:(ModuleDescription*)moduleDescription atPoint:(CGPoint)point forComponentID:(NSString*)componentID;
-(CGRect)rectForCellSet:(NSSet*)cellSet;

-(void)forceDisconnect:(NSDictionary*)userInfo;

-(NSDictionary*)getDictionary;
-(void)rebuildFromDictionary:(NSDictionary*)dictionary;

-(void)removeAll;

@end
