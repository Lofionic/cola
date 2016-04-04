//
//  BuildView.m
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "BuildView.h"
#import "ModuleView.h"
#import "BuildViewGridLayer.h"
#import "BuildViewHighlightLayer.h"
#import "BuildViewCableLayer.h"
#import "BuildViewController.h"
#import "ModuleDescription.h"
#import "MasterModuleView.h"
#import "ModuleCatalog.h"
#import "ControlView.h"
#import "BuildViewScrollView.h"

#import <ColaLib/COLAudioEnvironment.h>

@interface BuildView () {
    bool cellOccupied[256][256];
}

@property (nonatomic, strong) ConnectorView *draggingConnector;

@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) NSUInteger rows;
@property (nonatomic) NSUInteger columns;

@property (nonatomic, strong) BuildViewGridLayer        *gridLayer;
@property (nonatomic, strong) BuildViewHighlightLayer   *highlightLayer;
@property (nonatomic, strong) BuildViewCableLayer       *cableLayer;
@property (nonatomic, strong) UIView                    *cableView;

@property (nonatomic, strong) NSMutableArray            *cables;
@property (nonatomic, strong) BuildViewCable            *dragCable;

@property (nonatomic, strong) ModuleView                *draggingModuleView;
@property (nonatomic) CGPoint                           dragOrigin;

@property (nonatomic, strong) UIView                    *trashView;

@property (nonatomic, strong) NSMutableArray            *moduleViews;

@property (nonatomic, strong) MasterModuleView          *masterModuleView;
@property (nonatomic, weak) BuildViewScrollView         *scrollView;

@end

@implementation BuildView

static NSArray *cableColours;

-(instancetype)initWithScrollView:(BuildViewScrollView *)scrollView {
    
    self = [super init];
    if (self) {
        self.scrollView = scrollView;

        self.columns = kBuildViewWidth / kBuildViewColumnWidth;
        self.rows = 4;
        
        CGFloat columnWidth = kBuildViewColumnWidth;
        CGFloat rowHeight = kBuildViewRowHeight;
        
        self.cellSize = CGSizeMake(columnWidth, rowHeight);
        self.headerHeight = 64;
        
        CGSize buildViewSize = CGSizeMake(
                                      kBuildViewWidth + (kBuildViewPadding * 2.0),
                                      (self.rows * self.cellSize.height) + self.headerHeight
                                      );
        
        [self setFrame:CGRectMake(kBuildViewPadding, 0, kBuildViewWidth, buildViewSize.height)];
        [self.scrollView setContentSize:buildViewSize];
        
        [self addLayers];
        
        self.cables = [[NSMutableArray alloc] initWithCapacity:200];
        self.moduleViews = [[NSMutableArray alloc] initWithCapacity:100];
        
        self.masterModuleView = [[MasterModuleView alloc] initWithFrame:CGRectMake(0, 0, kBuildViewWidth, self.headerHeight) buildView:self];
        [self addSubview:self.masterModuleView];
        
        self.trashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBuildViewWidth, self.headerHeight)];
        [self.trashView setBackgroundColor:[UIColor whiteColor]];
        [self.trashView setAlpha:0];
        [self addSubview:self.trashView];
        
        [self bringSubviewToFront:self.cableView];
        
        self.cableBehaviour = BuildViewCableBehaviourDrag;
    }
    return self;
}


-(void)addLayers {
    self.gridLayer = [BuildViewGridLayer layer];
    [self.gridLayer setBuildView:self];
    [self.gridLayer setFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
    [self.gridLayer setNeedsDisplay];
    [self.layer addSublayer:self.gridLayer];
    
    self.highlightLayer = [BuildViewHighlightLayer layer];
    [self.highlightLayer setBuildView:self];
    [self.highlightLayer setFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
    [self.highlightLayer setNeedsDisplay];
    [self.layer addSublayer:self.highlightLayer];
    
    self.cableLayer = [BuildViewCableLayer layer];
    [self.cableLayer setBuildView:self];
    [self.cableLayer setFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
    [self.cableLayer setNeedsDisplay];
    
    self.cableView = [[UIView alloc] initWithFrame:self.bounds];
    [self.cableView  setUserInteractionEnabled:NO];
    [self.cableView  setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    [self.cableView .layer addSublayer:self.cableLayer];
    [self addSubview:self.cableView ];
    [self bringSubviewToFront:self.cableView];
}

-(void)setTrashViewHidden:(BOOL)hidden {

    if (hidden) {
        [UIView animateWithDuration:0.2 animations:^ {
            [self.trashView setAlpha:0];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^ {
            [self.trashView setAlpha:1];
        }];
    }
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
    if (point.x >= 0 && point.x <= self.scrollView.contentSize.width &&
        point.y >= self.headerHeight && point.y <= self.scrollView.contentSize.height) {
    
        NSUInteger column = point.x / self.cellSize.width;
        NSUInteger row = (point.y - self.headerHeight) / self.cellSize.height;
        
        return [[BuildViewCellPath alloc] initWithColumn:column Row:row];
    } else {
        return nil;
    }
}

-(NSSet*)cellPathsForModuleOfWidth:(NSUInteger)width center:(CGPoint)center occupied:(BOOL*)occupied {
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
    __block BOOL isOccupied = NO;
    [result enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
        if (cellOccupied[cellPath.row][cellPath.column]) {
            isOccupied = YES;
            *stop = YES;
        }
    }];
    
    if (occupied) {
        *occupied = isOccupied;
    }
    return [NSSet setWithSet:result];
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

-(ModuleView*)addViewForModule:(ModuleDescription*)moduleDescription atPoint:(CGPoint)point forComponentID:(NSString*)componentID {
    BOOL occupied;
    NSSet *cellSet = [self cellPathsForModuleOfWidth:moduleDescription.width center:point occupied:&occupied];
    
    if (cellSet && !occupied) {
        
        CGRect newFrame = [self rectForCellSet:cellSet];
        ModuleView *moduleView = [[ModuleView alloc] initWithModuleDescription:moduleDescription inFrame:newFrame componentID:componentID];
        
        if (moduleView) {
            [moduleView setDelegate:self];
            [self addSubview:moduleView];
            [self bringSubviewToFront:self.cableView];
            
            // Add cells to occupied
            [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
                cellOccupied[cellPath.row][cellPath.column] = TRUE;
            }];
            
            [self.moduleViews addObject:moduleView];
            
            return moduleView;
        }
    }
    return nil;
}

#pragma mark Cable Management

-(void)connectorView:(ConnectorView *)connectorView didBeginDrag:(UIPanGestureRecognizer *)uigr {
    
    if (!connectorView.cable || self.cableBehaviour == BuildViewCableBehaviourDraw) {
        // Connector view is not connected or draw behaviour is enabled
        self.draggingConnector = connectorView;
        
        CGPoint point1 = [self convertPoint:connectorView.center fromView:connectorView.superview];
        CGPoint point2 = [uigr locationInView:self];
        self.dragCable = [[BuildViewCable alloc] initWithPoint:point1 andPoint:point2 inBuildView:self];
        
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
    } else{
        // Connector view is connected and drag behaviour is enabled
        UIColor *cableColour = connectorView.cable.colour;
        
        [self.cables removeObject:connectorView.cable];
        [self.cableLayer setNeedsDisplay];
        [self disconnectConnectorView:connectorView];
        
        if (connectorView == connectorView.cable.connector1) {
            self.draggingConnector = connectorView.cable.connector2;
        } else {
            self.draggingConnector = connectorView.cable.connector1;
        }
        
        CGPoint point1 = [self convertPoint:self.draggingConnector.center fromCoordinateSpace:self.draggingConnector.superview];
        CGPoint point2 = [uigr locationInView:self];
        self.dragCable = [[BuildViewCable alloc] initWithPoint:point1 andPoint:point2 inBuildView:self];
        [self.dragCable setColour:cableColour];
        
    }
    
    [self.scrollView setEnableAutoscroll:YES];
    [self.cables addObject:self.dragCable];
}

-(void)connectorView:(ConnectorView *)connectorView didContinueDrag:(UIPanGestureRecognizer *)uigr {
    
    [self.dragCable setPoint2:[uigr locationInView:self]];
    [self.cableLayer setNeedsDisplay];
}

-(void)connectorView:(ConnectorView *)connectorView didEndDrag:(UIPanGestureRecognizer *)uigr {
    [self.scrollView setEnableAutoscroll:NO];
    [self.cables removeObject:self.dragCable];
    
    // In case we are changing a connection rather than drawing a new one
    connectorView = self.draggingConnector;

    UIView *hitView = [self hitTest:[uigr locationInView:self] withEvent:nil];
    if ([hitView isKindOfClass:[ConnectorView class]]) {
        
        ConnectorView *hitConnector = (ConnectorView*)hitView;
        
        ConnectorView *outConnector;
        ConnectorView *inConnector;
        
        COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
        kIOType hitConnectorType = [cae getConnectorType:hitConnector.connector];
        
        if (hitConnectorType & kIOTypeOutput) {
            outConnector = hitConnector;
            inConnector = connectorView;
        } else {
            outConnector = connectorView;
            inConnector = hitConnector;
        }
        
        if ([self connectorView:outConnector connectWith:inConnector]) {
            if (inConnector.cable) {
                [self.cables removeObject:inConnector.cable];
            }
            
            if (outConnector.cable) {
                [self.cables removeObject:outConnector.cable];
            }
            
            // Successful connection
            [self addCableFrom:connectorView to:hitConnector withColour:self.dragCable.colour];
        }
    }
    self.dragCable = nil;
    [self.cableLayer setNeedsDisplay];
}

-(void)addCableFrom:(ConnectorView*)connectorView1 to:(ConnectorView*)connectorView2 withColour:(UIColor*)colour {
    CGPoint point1 = [self convertPoint:connectorView1.center fromView:connectorView1.superview];
    CGPoint point2 = [self convertPoint:connectorView2.center fromView:connectorView2.superview];
    
    BuildViewCable *newCable = [[BuildViewCable alloc] initWithPoint:point1 andPoint:point2 inBuildView:self];
    [newCable setColour:colour];
    [connectorView1 setCable:newCable];
    [connectorView2 setCable:newCable];
    
    [newCable setConnector1:connectorView1];
    [newCable setConnector2:connectorView2];
    
    [self.cables addObject:newCable];
    [self.cableLayer setNeedsDisplay];
}

-(BOOL)connectorView:(ConnectorView*)connectorView1 connectWith:(ConnectorView*)connectorView2 {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    CCOLConnectorAddress componentIO1 = connectorView1.connector;
    CCOLConnectorAddress componentIO2 = connectorView2.connector;
    
    kIOType ioType1 = [cae getConnectorType:componentIO1];
    kIOType ioType2 = [cae getConnectorType:componentIO2];
    
    if ((ioType1 & kIOTypeOutput) && (ioType2 & kIOTypeInput)) {
        return [cae connectOutput:componentIO1 toInput:componentIO2];
    }
    
    return NO;
}

-(void)disconnectConnectorView:(ConnectorView*)connectorView {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    [cae disconnect:connectorView.connector];
}

-(void)forceDisconnect:(NSDictionary *)userInfo {
    // The engine has forced a disconnect, we need to update the UI to reflect this
    CCOLOutputAddress disconnectedOutput = (CCOLComponentAddress)[[userInfo objectForKey:@"output"] unsignedLongLongValue];

    for (BuildViewCable *thisCable in [self.cables copy]) {
        if (thisCable.connector1.connector == disconnectedOutput || thisCable.connector2.connector == disconnectedOutput) {
            [self disconnectConnectorView:thisCable.connector1];
            [self.cables removeObject:thisCable];
        }
    }
}

+(NSArray*)cableColours {
    if (!cableColours) {
        cableColours = @[[UIColor colorWithRed:196/255.0 green:0 blue:0 alpha:1.0],
                         [UIColor colorWithRed:0 green:128/255.0 blue:0 alpha:1.0],
                         [UIColor colorWithRed:0 green:0 blue:196/255.0 alpha:1.0],
                         [UIColor colorWithRed:1.0 green:220/255.0 blue:0 alpha:1.0],
                         [UIColor colorWithRed:1.0 green:128/255.0 blue:0 alpha:1.0]];
    }
    
    return cableColours;
}

#pragma ModuleViewDelegate

-(void)moduleView:(ModuleView *)moduleView didBeginDraggingWithGesture:(UIGestureRecognizer *)gesture {
    if ([self.buildViewController buildMode]) {
        [self popModuleView:moduleView];
        [self.scrollView setEnableAutoscroll:YES];
        
        CGPoint dragPoint = [gesture locationInView:self];
        [self.draggingModuleView setCenter:dragPoint];
        
        [self.cableView setHidden:YES];
        [self setTrashViewHidden:NO];
    }
}

-(void)moduleView:(ModuleView *)moduleView didContinueDraggingWithGesture:(UIGestureRecognizer *)gesture {
    if (self.draggingModuleView) {
        
        CGPoint dragPoint;
        
        dragPoint = [gesture locationInView:self];
        
        [self.draggingModuleView setCenter:dragPoint];
        
        BOOL occupied;
        NSSet *hoverSet = [self cellPathsForModuleOfWidth:moduleView.moduleDescription.width center:dragPoint occupied:&occupied];
        
        if (hoverSet && !occupied && [self.superview hitTest:[gesture locationInView:self.superview] withEvent:nil] == self) {
            [self setHighlightedCellSet:hoverSet];
        } else {
            [self setHighlightedCellSet:nil];
        }
    }
}

-(void)moduleView:(ModuleView *)moduleView didEndDraggingWithGesture:(UIGestureRecognizer *)gesture {
    
    [self.scrollView setEnableAutoscroll:NO];
    
    if (self.draggingModuleView) {
        
        [self setHighlightedCellSet:nil];
        
        UIView *hitView = [self hitTest:[gesture locationInView:self] withEvent:nil];
        if (hitView == self.trashView) {
            
            // Module was trashed
            [self trashModuleView:moduleView];
            self.draggingModuleView = nil;
            
        } else {
            
            [self.draggingModuleView.layer setOpacity:1.0];
            
            BOOL modulePlaced = NO;
            
            if (gesture.state != UIGestureRecognizerStateCancelled ){
                if ([self.superview hitTest:[gesture locationInView:self.superview] withEvent:nil] == self) {
                    // Move the module
                    modulePlaced = [self placeModuleView:self.draggingModuleView toPoint:[gesture locationInView:self]];
                }
            }
            
            if (!modulePlaced) {
                // Module was not succesfully placed
                // Bounce it back
                [self placeModuleView:self.draggingModuleView toPoint:self.dragOrigin];
            }
            
            self.draggingModuleView = nil;
        }
        
        [self.cableView setHidden:NO];
        [self setTrashViewHidden:YES];
    }
}

-(NSInteger)getRowForX:(CGFloat)x {
    return floor(x / self.cellSize.width);
}

-(NSInteger)getColumnForY:(CGFloat)y {
    return floor(y / self.cellSize.height);
}

-(void)trashModuleView:(ModuleView*)moduleView {
    
    // Remove any cables connected to this module
    for (ConnectorView *thisConnector in moduleView.connectorViews) {
        if (thisConnector.cable) {
            [self.cables removeObject:thisConnector.cable];
        }
    }
    [self.cableLayer setNeedsDisplay];

    // Remove from module dictionary
    [self.moduleViews removeObject:moduleView];

    // Trash the module
    [moduleView trash];
}


-(void)popModuleView:(ModuleView*)moduleView {
    self.draggingModuleView = moduleView;
    self.dragOrigin = moduleView.center;
    [self.draggingModuleView.layer setOpacity:0.5];
    [moduleView.superview bringSubviewToFront:moduleView];
    
    [moduleView setUserInteractionEnabled:NO];
    
    // Deoccupy cells
    NSSet *cellSet = [self cellPathsForModuleOfWidth:moduleView.moduleDescription.width center:moduleView.center occupied:nil];
    [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
        cellOccupied[cellPath.row][cellPath.column] = FALSE;
    }];
}

-(BOOL)placeModuleView:(ModuleView*)moduleView toPoint:(CGPoint)point {
    BOOL occupied;
    NSSet *cellSet = [self cellPathsForModuleOfWidth:moduleView.moduleDescription.width center:point occupied:&occupied];
    
    [moduleView setUserInteractionEnabled:YES];
    
    if (cellSet && !occupied) {
        [moduleView setFrame:[self rectForCellSet:cellSet]];
        
        // Add cells to occupied
        [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
            cellOccupied[cellPath.row][cellPath.column] = TRUE;
        }];
        
        // Update cables
        for (BuildViewCable *thisCable in self.cables) {
            if (thisCable.connector1.superview == moduleView || thisCable.connector2.superview == moduleView) {
                [thisCable updatePoints];
            }
        }
        
        [self bringSubviewToFront:self.cableView];
        [self.cableLayer setNeedsDisplay];
        
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Load & Save
-(NSDictionary*)getDictionary {
    // Create a dictionary of all the data needed to reassemble the build view.
    
    // Modules
    NSMutableArray *modules = [[NSMutableArray alloc] initWithCapacity:[self.moduleViews count]];
    for (ModuleView *thisModuleView in self.moduleViews) {
        [modules addObject:[thisModuleView getDictionary]];
    }
    
    // Cables
    NSMutableArray *cables = [[NSMutableArray alloc] initWithCapacity:self.cables.count];
    for (BuildViewCable *thisCableView in self.cables) {
        [cables addObject:thisCableView.getDictionary];
    }
    
    return @{
             PRESET_KEY_VIEW_MODULES    : modules,
             PRESET_KEY_VIEW_CABLES     : cables
             };
}

-(void)rebuildFromDictionary:(NSDictionary*)dictionary {

    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    
    // Add the module views to the build view.
    NSArray *modules = [dictionary objectForKey:PRESET_KEY_VIEW_MODULES];
    NSMutableDictionary *moduleIdentifiers = [[NSMutableDictionary alloc] initWithCapacity:modules.count + 2];
    for (NSDictionary *thisModule in modules) {
        NSInteger x = ([[thisModule objectForKey:PRESET_KEY_MODULE_COLUMN] integerValue] + 0.5f) * self.cellSize.width;
        NSInteger y = ([[thisModule objectForKey:PRESET_KEY_MODULE_ROW] integerValue] + 0.5f) * self.cellSize.height;
        ModuleDescription *moduleDescription = [[ModuleCatalog sharedCatalog] moduleWithIdentifier:[thisModule objectForKey:PRESET_KEY_MODULE_TYPE]];
        if (moduleDescription) {
            ModuleView *newModule = [self addViewForModule:moduleDescription atPoint:CGPointMake(x, y) forComponentID:[thisModule objectForKey:PRESET_KEY_MODULE_COMPONENT_ID]];
            if (newModule) {
                [moduleIdentifiers setObject:newModule forKey:[thisModule objectForKey:PRESET_KEY_MODULE_COMPONENT_ID]];
            }
        }
    }
    
    // We need to hook up MIDI & master connectors too. These are in the master module.
    [moduleIdentifiers setObject:self.masterModuleView forKey:[cae getComponentID:[cae getMIDIComponent]]];
    [moduleIdentifiers setObject:self.masterModuleView forKey:[cae getComponentID:[cae getMasterComponent]]];
    
    // Add the cables to the build view
    NSArray *cables = [dictionary objectForKey:PRESET_KEY_VIEW_CABLES];
    for (NSDictionary *thisCable in cables) {
        ModuleView *fromModule = [moduleIdentifiers objectForKey:[thisCable objectForKey:PRESET_KEY_CONNECTION_FROM_COMPONENT]];
        ModuleView *toModule = [moduleIdentifiers objectForKey:[thisCable objectForKey:PRESET_KEY_CONNECTION_TO_COMPONENT]];
        
        if (fromModule && toModule) {
            ConnectorView *fromConnector = [fromModule connectorForName:[thisCable objectForKey:PRESET_KEY_CONNECTION_FROM_OUTPUT]];
            ConnectorView *toConnector = [toModule connectorForName:[thisCable objectForKey:PRESET_KEY_CONNECTION_TO_INPUT]];
            
            if (fromConnector && toConnector) {
                [self addCableFrom:fromConnector to:toConnector withColour:[thisCable objectForKey:PRESET_KEY_CONNECTION_CABLE_COLOUR]];
            }
        }
    }
}

-(void)removeAllModules {
    NSLog(@"Removing all modules");
    
    for (ModuleView *thisModuleView in self.moduleViews) {
        [thisModuleView trash];
    }
    
    [self.moduleViews removeAllObjects];
    
    [self.cables removeAllObjects];
    [self.cableLayer setNeedsDisplay];
    
    for (NSUInteger i = 0; i < 256; i++) {
        for (NSUInteger j = 0; j < 256; j++) {
            cellOccupied[i][j] = NO;
        }
    }
    
    [[COLAudioEnvironment sharedEnvironment] allNotesOff];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // If the build scrollview scrolls while we're dragging, we need to update the location of the thing we're dragging.
    if (self.draggingConnector) {
        // We are dragging a cable
        [self connectorView:self.draggingConnector didContinueDrag:[[self.draggingConnector gestureRecognizers] objectAtIndex:0]];
    } else if (self.draggingModuleView) {
        [self moduleView:self.draggingModuleView didContinueDraggingWithGesture:[[self.draggingModuleView gestureRecognizers] objectAtIndex:0]];
    }
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
-(instancetype)initWithPoint:(CGPoint)point1 andPoint:(CGPoint)point2 inBuildView:(BuildView *)buildView {
    self = [super init];
    if (self) {
        self.buildView = buildView;
        self.point1 = point1;
        self.point2 = point2;
        
        self.colour = [UIColor redColor];
    }
    return self;
}

-(void)updatePoints {
    if (self.connector1) {
        self.point1 = [self.buildView convertPoint:self.connector1.center fromView:self.connector1.superview];
    }
    
    if (self.connector2) {
        self.point2 = [self.buildView convertPoint:self.connector2.center fromView:self.connector2.superview];
    }
}
        
-(NSDictionary*)getDictionary {
    COLAudioEnvironment *cae = [COLAudioEnvironment sharedEnvironment];
    return @{
             PRESET_KEY_CONNECTION_FROM_COMPONENT   : [cae getComponentID:[cae getConnectorComponent:self.connector1.connector]],
             PRESET_KEY_CONNECTION_FROM_OUTPUT      : [cae getConnectorName:self.connector1.connector],
             PRESET_KEY_CONNECTION_TO_COMPONENT     : [cae getComponentID:[cae getConnectorComponent:self.connector2.connector]],
             PRESET_KEY_CONNECTION_TO_INPUT         : [cae getConnectorName:self.connector2.connector],
             PRESET_KEY_CONNECTION_CABLE_COLOUR     : self.colour
             };
}

@end