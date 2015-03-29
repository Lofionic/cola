//
//  BuildView.m
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "BuildView.h"
#import "defines.h"
#import "ModuleView.h"
#import "BuildViewGridLayer.h"
#import "BuildViewHighlightLayer.h"
#import "BuildViewCableLayer.h"

#import <ColaLib/ColaLib.h>

@interface BuildView () {
    bool cellOccupied[256][256];

}

@property (nonatomic, strong) ConnectorView *draggingConnector;

@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) NSUInteger rows;
@property (nonatomic) NSUInteger columns;

@property (nonatomic, strong) NSMutableSet *occupiedCells;

@property (nonatomic, strong) BuildViewGridLayer *gridLayer;
@property (nonatomic, strong) BuildViewHighlightLayer *highlightLayer;
@property (nonatomic, strong) BuildViewCableLayer *cableLayer;

@property (nonatomic, strong) NSMutableArray *cables;
@property (nonatomic, strong) BuildViewCable *dragCable;

@end


@implementation BuildView

static NSArray *cableColours;

-(instancetype)init {
    self = [super init];
    if (self) {
        self.columns = kBuildViewWidth / kBuildViewColumnWidth;
        self.rows = 4;
        
        CGFloat columnWidth = kBuildViewColumnWidth;
        CGFloat rowHeight = kBuildViewRowHeight;
        
        self.cellSize = CGSizeMake(columnWidth, rowHeight);
        self.headerHeight = 64;
        
        self.contentSize = CGSizeMake(
                                      self.columns * self.cellSize.width,
                                      (self.rows * self.cellSize.height) + self.headerHeight
                                      );

        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0.0 alpha:1]];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        
        self.occupiedCells = [[NSMutableSet alloc] initWithCapacity:self.columns * self.rows];
        [self setDelegate:self];
        self.delaysContentTouches = NO;
        
        [self addGlobalIO];
        [self addLayers];
        
        self.cables = [[NSMutableArray alloc] initWithCapacity:200];
    }
    return self;
}


-(void)addLayers {
    self.gridLayer = [BuildViewGridLayer layer];
    [self.gridLayer setBuildView:self];
    [self.gridLayer setFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    [self.gridLayer setNeedsDisplay];
    [self.layer addSublayer:self.gridLayer];
    
    self.highlightLayer = [BuildViewHighlightLayer layer];
    [self.highlightLayer setBuildView:self];
    [self.highlightLayer setFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    [self.highlightLayer setNeedsDisplay];
    [self.layer addSublayer:self.highlightLayer];
    
    self.cableLayer = [BuildViewCableLayer layer];
    [self.cableLayer setBuildView:self];
    [self.cableLayer setFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    [self.cableLayer setNeedsDisplay];
    [self.layer insertSublayer:self.cableLayer above:self.layer];
    [self.cableLayer setZPosition:1.0];

}

-(void)addGlobalIO {
    COLComponentIO *mainIn = [[COLAudioContext globalContext] masterInputAtIndex:0];
    ConnectorView *mainInConnectorView = [[ConnectorView alloc] initWithComponentIO:mainIn];
    [mainInConnectorView setCenter:CGPointMake(24, self.headerHeight / 2.0)];
    [mainInConnectorView setDelegate:self];
    [self addSubview:mainInConnectorView];
    
    COLComponentIO *keyboardOut = [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] outputForIndex:0];
    ConnectorView *keyboardOutView = [[ConnectorView alloc] initWithComponentIO:keyboardOut];
    [keyboardOutView setCenter:CGPointMake(120, self.headerHeight / 2.0)];
    [keyboardOutView setDelegate:self];
    [self addSubview:keyboardOutView];
    
    COLComponentIO *keyboardGate = [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] outputForIndex:1];
    ConnectorView *keyboardGateView = [[ConnectorView alloc] initWithComponentIO:keyboardGate];
    [keyboardGateView setCenter:CGPointMake(168, self.headerHeight / 2.0)];
    [keyboardGateView setDelegate:self];
    [self addSubview:keyboardGateView];
}

@synthesize highlightedCellSet = _highlightedCellSet;

-(NSSet*)highlightedCellSet {
    return _highlightedCellSet;
}

-(void)setHighlightedCellSet:(NSSet *)highlightedCellSet {
    if (![_highlightedCellSet isEqualToSet:highlightedCellSet]) {
        // Highlighted cell set has changed
        _highlightedCellSet = highlightedCellSet;
        [self.highlightLayer setNeedsDisplay];
    }
}

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point {
    // Return the cell path for a point within the view's coordinate space
    if (point.x >= 0 && point.x <= self.contentSize.width &&
        point.y >= self.headerHeight && point.y <= self.contentSize.height) {
    
        NSUInteger column = point.x / self.cellSize.width;
        NSUInteger row = (point.y - self.headerHeight) / self.cellSize.height;
        
        return [[BuildViewCellPath alloc] initWithColumn:column Row:row];
    } else {
        return nil;
    }
}

-(NSSet*)cellPathsForModuleOfWidth:(NSUInteger)width center:(CGPoint)center {
    NSInteger height = 1;
    CGPoint minPoint = CGPointMake(
                                   center.x - ((width - 1) * self.cellSize.width) / 2.0,
                                   (center.y - self.headerHeight) - ((height - 1) * self.cellSize.height) / 2.0
                                   );
    
    NSInteger minX = minPoint.x / self.cellSize.width;
    NSInteger minY = minPoint.y / self.cellSize.height;
    
    if (minX < 0) {
        minX = 0;
    }
    
    if (minY < 0) {
        minY = 0;
    }
    
    NSInteger maxX = minX + width;
    NSInteger maxY = minY + height;
    
    while (maxX > self.columns) {
        minX--;
        maxX = minX + width;
        if (minX < 0) {
            return nil;
        }
    }
    
    while (maxY > self.rows) {
        minY--;
        maxY = minY + height;
        if (minY < 0) {
            return nil;
        }
    }
    
    NSMutableSet *result = [[NSMutableSet alloc] initWithCapacity:self.rows * self.columns];
    
    for (NSInteger x = minX; x < maxX; x++) {
        for (NSInteger y = minY; y < maxY; y++) {
            [result addObject:[[BuildViewCellPath alloc] initWithColumn:x Row:y]];
        }
    }
    
    // Check if any cells are occupied
    __block BOOL occupied = NO;
    [result enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
        if (cellOccupied[cellPath.row][cellPath.column]) {
            occupied = YES;
            *stop = YES;
        }
    }];
    
    if (!occupied) {
        return [NSSet setWithSet:result];
    } else {
        return nil;
    }
}

-(CGRect)rectForCellSet:(NSSet*)cellSet {
    
    __block NSInteger left = self.columns;
    __block NSInteger top = self.rows;
    __block NSInteger right = 0;
    __block NSInteger bottom = 0;
    
    [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
        
        if (cellPath.column < left) {
            left = cellPath.column;
        }
        
        if (cellPath.column > right) {
            right = cellPath.column;
        }
        
        if (cellPath.row < top) {
            top = cellPath.row;
        }
        
        if (cellPath.row > bottom) {
            bottom = cellPath.row;
        }
    }];
    
    CGRect result = CGRectMake(left * self.cellSize.width, (top * self.cellSize.height) + self.headerHeight, (right - left + 1) * self.cellSize.width, (bottom - top + 1) * self.cellSize.height);
    return result;
}

-(UIView*)addViewForModule:(ModuleDescription*)moduleDescription atPoint:(CGPoint)point {
    NSSet *cellSet = [self cellPathsForModuleOfWidth:moduleDescription.width center:point];
    
    if (cellSet) {
        
        CGRect newFrame = [self rectForCellSet:cellSet];
        ModuleView *moduleView = [[ModuleView alloc] initWithModuleDescription:moduleDescription inFrame:newFrame];

        if (moduleView) {

            [self addSubview:moduleView];
            
            // Add cells to occupied
            [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
                cellOccupied[cellPath.row][cellPath.column] = TRUE;
            }];
            
            return moduleView;
        }
    }
    return nil;
}

-(COLComponent*)componentForModuleDescription:(ModuleDescription*)moduleDescription {
    COLComponent *result = [[COLAudioEnvironment sharedEnvironment] createComponentOfType:moduleDescription.type];
    return result;
}

#pragma mark ConnectorView Delegate

-(void)connectorView:(ConnectorView *)connectorView didBeginDrag:(UIPanGestureRecognizer *)uigr {
    self.draggingConnector = connectorView;
    
    CGPoint point1 = [self convertPoint:connectorView.center fromView:connectorView.superview];
    CGPoint point2 = [uigr locationInView:self];
    self.dragCable = [[BuildViewCable alloc] initWithPoint:point1 andPoint:point2];
    
    // Remove any cables connected to this connector
    if (connectorView.cable) {
        [self.dragCable setColour:connectorView.cable.colour];
        [self.cables removeObject:connectorView.cable];
        [self.cableLayer setNeedsDisplay];
        [self disconnectConnectorView:connectorView];
    } else {
        NSInteger randomColour = arc4random_uniform((UInt32)[[BuildView cableColours] count]);
        [self.dragCable setColour:[[BuildView cableColours] objectAtIndex:randomColour]];
    }
    
    [self.cables addObject:self.dragCable];
}

-(void)connectorView:(ConnectorView *)connectorView didContinueDrag:(UIPanGestureRecognizer *)uigr {
    [self.dragCable setPoint2:[uigr locationInView:self]];
    [self.cableLayer setNeedsDisplay];
}

-(void)connectorView:(ConnectorView *)connectorView didEndDrag:(UIPanGestureRecognizer *)uigr {
    [self.cables removeObject:self.dragCable];
    
    UIView *hitView = [self hitTest:[uigr locationInView:self] withEvent:nil];
    if ([hitView isKindOfClass:[ConnectorView class]]) {
        ConnectorView *hitConnector = (ConnectorView*)hitView;
        if ([self connectorView:connectorView connectWith:hitConnector]) {
            if (hitConnector.cable) {
                [self.cables removeObject:hitConnector.cable];
            }
            // Successful connection
            CGPoint point1 = [self convertPoint:connectorView.center fromView:connectorView.superview];
            CGPoint point2 = [self convertPoint:hitConnector.center fromView:hitConnector.superview];
            
            BuildViewCable *newCable = [[BuildViewCable alloc] initWithPoint:point1 andPoint:point2];
            [newCable setColour:[self.dragCable colour]];
            [connectorView setCable:newCable];
            [hitConnector setCable:newCable];
            
            [self.cables addObject:newCable];
        }
    }
    self.dragCable = nil;
    [self.cableLayer setNeedsDisplay];
}

-(BOOL)connectorView:(ConnectorView*)connectorView1 connectWith:(ConnectorView*)connectorView2 {
    COLComponentIO *componentIO1 = connectorView1.componentIO;
    COLComponentIO *componentIO2 = connectorView2.componentIO;
    
    if ([componentIO1 isKindOfClass:[COLComponentOutput class]] && [componentIO2 isKindOfClass:[COLComponentInput class]]) {
        COLComponentOutput *output = (COLComponentOutput*)componentIO1;
        COLComponentInput *input = (COLComponentInput*)componentIO2;
        return [output connectTo:input];
    }
    
    return NO;
}

-(void)disconnectConnectorView:(ConnectorView*)connectorView {
    COLComponentIO *componentIO = connectorView.componentIO;
    if (componentIO) {
        [componentIO disconnect];
    }
}

+(NSArray*)cableColours {
    if (!cableColours) {
        cableColours = @[[UIColor redColor], [UIColor blueColor], [UIColor yellowColor], [UIColor greenColor], [UIColor orangeColor], [UIColor blackColor], [UIColor lightGrayColor]];
    }
    
    return cableColours;
}

@end

@interface BuildViewCellPath ()
@property (nonatomic) NSUInteger column;
@property (nonatomic) NSUInteger row;
@end

@implementation BuildViewCellPath
-(instancetype)initWithColumn:(NSUInteger)column Row:(NSUInteger)row {
    self = [super init];
    if (self) {
        self.row = row;
        self.column = column;
    }
    return self;
}
@end

@implementation BuildViewCable
-(instancetype)initWithPoint:(CGPoint)point1 andPoint:(CGPoint)point2 {
    self = [super init];
    if (self) {
        self.point1 = point1;
        self.point2 = point2;
        
        self.colour = [UIColor redColor];
    }
    return self;
}
@end