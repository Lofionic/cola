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
#import "BuildViewController.h"
#import "ModuleDescription.h"
#import "MasterModuleView.h"
#import "ModuleCatalog.h"
#import "ModuleControl.h"
#import <ColaLib/ColaLib.h>

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

@property (nonatomic, strong) ModuleView                *dragView;
@property (nonatomic) CGPoint                           dragOrigin;

@property (nonatomic, strong) UIView                    *trashView;

@property (nonatomic, strong) NSMutableDictionary       *moduleViews;

@property (nonatomic, strong) MasterModuleView          *masterModuleView;
@property (nonatomic, weak) UIScrollView                *scrollView;

@end


@implementation BuildView

static NSArray *cableColours;

-(instancetype)initWithScrollView:(UIScrollView *)scrollView {
    
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
                                      kBuildViewWidth,
                                      (self.rows * self.cellSize.height) + self.headerHeight
                                      );
        
        [self setFrame:CGRectMake(0, 0, kBuildViewWidth, buildViewSize.height)];
        [self.scrollView setContentSize:buildViewSize];

        [self.scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        self.scrollView.delaysContentTouches = NO;
        
        [self addLayers];
        
        self.cables = [[NSMutableArray alloc] initWithCapacity:200];
        self.moduleViews = [[NSMutableDictionary alloc] initWithCapacity:100];
        
        self.masterModuleView = [[MasterModuleView alloc] initWithFrame:CGRectMake(0, 0, kBuildViewWidth, self.headerHeight) buildView:self];
        [self addSubview:self.masterModuleView];
        
        self.trashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBuildViewWidth, self.headerHeight)];
        [self.trashView setBackgroundColor:[UIColor whiteColor]];
        [self.trashView setAlpha:0];
        [self addSubview:self.trashView];
        
        [self bringSubviewToFront:self.cableView];
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

-(ModuleView*)addViewForModule:(ModuleDescription*)moduleDescription atPoint:(CGPoint)point identifier:(NSString*)identifier {
    BOOL occupied;
    NSSet *cellSet = [self cellPathsForModuleOfWidth:moduleDescription.width center:point occupied:&occupied];
    
    if (cellSet && !occupied) {
        
        CGRect newFrame = [self rectForCellSet:cellSet];
        ModuleView *moduleView = [[ModuleView alloc] initWithModuleDescription:moduleDescription inFrame:newFrame identifier:identifier];
        
        if (moduleView) {
            [moduleView setDelegate:self];
            [self addSubview:moduleView];
            [self bringSubviewToFront:self.cableView];
            
            // Add cells to occupied
            [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
                cellOccupied[cellPath.row][cellPath.column] = TRUE;
            }];
            
            [self.moduleViews setObject:moduleView forKey:moduleView.identifier];
            
            return moduleView;
        }
    }
    return nil;
}

#pragma mark Cable Management

-(void)connectorView:(ConnectorView *)connectorView didBeginDrag:(UIPanGestureRecognizer *)uigr {
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
        
        ConnectorView *outConnector;
        ConnectorView *inConnector;
        if ([hitConnector.componentIO isKindOfClass:[COLComponentOutput class]]) {
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
        cableColours = @[[UIColor redColor],
                         [UIColor blueColor],
                         [UIColor yellowColor],
                         [UIColor greenColor],
                         [UIColor orangeColor],
                         [UIColor grayColor],
                         [UIColor lightGrayColor],
                         [UIColor purpleColor],
                         [UIColor brownColor],
                         [UIColor cyanColor],
                         [UIColor magentaColor]];
    }
    
    return cableColours;
}

#pragma ModuleViewDelegate

-(void)moduleView:(ModuleView *)moduleView didBeginDraggingWithGesture:(UIGestureRecognizer *)gesture {
    if ([self.buildViewController buildMode]) {
        [self popModuleView:moduleView];
        
        CGPoint dragPoint = [gesture locationInView:self];
        [self.dragView setCenter:dragPoint];
        
        [self.cableView setHidden:YES];
        [self setTrashViewHidden:NO];
    }
}

-(void)moduleView:(ModuleView *)moduleView didContinueDraggingWithGesture:(UIGestureRecognizer *)gesture {
    if (self.dragView) {
        
        CGPoint dragPoint = [gesture locationInView:self];
        
        dragPoint = [gesture locationInView:self];
        
        [self.dragView setCenter:dragPoint];
        
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

    
    if (self.dragView) {
        
        [self setHighlightedCellSet:nil];
        
        UIView *hitView = [self hitTest:[gesture locationInView:self] withEvent:nil];
        if (hitView == self.trashView) {
            
            // Module was trashed
            [self trashModuleView:moduleView];
            self.dragView = nil;
            
        } else {
            
            [self.dragView.layer setOpacity:1.0];
            
            BOOL modulePlaced = NO;
            
            if (gesture.state != UIGestureRecognizerStateCancelled ){
                if ([self.superview hitTest:[gesture locationInView:self.superview] withEvent:nil] == self) {
                    // Move the module
                    modulePlaced = [self placeModuleView:self.dragView toPoint:[gesture locationInView:self]];
                }
            }
            
            if (!modulePlaced) {
                // Module was not succesfully placed
                // Bounce it back
                [self placeModuleView:self.dragView toPoint:self.dragOrigin];
            }
            
            self.dragView = nil;
        }
        
        [self.cableView setHidden:NO];
        [self setTrashViewHidden:YES];
    }
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
    [self.moduleViews removeObjectForKey:moduleView.identifier];

    // Trash the module
    [moduleView trash];
    
}


-(void)popModuleView:(ModuleView*)moduleView {
    self.dragView = moduleView;
    self.dragOrigin = moduleView.center;
    [self.dragView.layer setOpacity:0.5];
    
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
        
        [self.cableLayer setNeedsDisplay];
        
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Load & Save

-(NSDictionary*)getPresetDictionary {
    // Create a dictionary of all the data needed to reassemble the patch
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:100]; // TODO: set capacity
    
    // Save modules
    NSMutableDictionary *modules = [[NSMutableDictionary alloc] initWithCapacity:[self.moduleViews count]];
    for (NSString *moduleKey in [self.moduleViews allKeys]) {

        ModuleView *moduleView = [self.moduleViews objectForKey:moduleKey];
        COLComponent *component = [moduleView component];
        
        NSMutableDictionary *parameterDictionary = [[NSMutableDictionary alloc] initWithCapacity:[component numberOfParameters]];
        
        for (NSUInteger i = 0; i < [component numberOfParameters]; i++) {
            COLParameter *parameter = [component parameterForIndex:i];
            
            NSNumber *value;
            if ([parameter isKindOfClass:[COLDiscreteParameter class]]) {
                COLDiscreteParameter *discreteParameter = (COLDiscreteParameter*)parameter;
                value = [NSNumber numberWithFloat:[discreteParameter selectedIndex]];
            } else if ([parameter isKindOfClass:[COLContinuousParameter class]]) {
                COLContinuousParameter *continuousParameter = (COLContinuousParameter*)parameter;
                value = [NSNumber numberWithFloat:[continuousParameter getNormalizedValue]];
            }
            
            [parameterDictionary setValue:value forKey:parameter.name];
        }
        
        NSDictionary *moduleDictionary = @{
                                           @"id"        :   moduleView.moduleDescription.identifier,
                                           @"params"    :   parameterDictionary,
                                           @"center"    :   [NSValue valueWithCGPoint:moduleView.center]
                                           };

        [modules setObject:moduleDictionary forKey:moduleKey];
    }
    [result setObject:[NSDictionary dictionaryWithDictionary:modules] forKey:@"modules"];
    
    // Save connections
    NSMutableArray *cables = [[NSMutableArray alloc] initWithCapacity:[self.cables count]];
    for (BuildViewCable *thisCable in self.cables) {
        
        ModuleView *outputModule = (ModuleView*)[thisCable.connector1 superview];
        NSString *outputConnection = thisCable.connector1.componentIO.name;
        ModuleView *inputModule = (ModuleView*)[thisCable.connector2 superview];
        NSString *inputConnection = thisCable.connector2.componentIO.name;
        
        NSDictionary *cableDictionary = @{
                                          @"outputModule"       : outputModule.identifier,
                                          @"outputConnection"   : outputConnection,
                                          @"inputModule"        : inputModule.identifier,
                                          @"inputConnection"    : inputConnection,
                                          @"colour"             : thisCable.colour
                                          };
        
        [cables addObject:cableDictionary];
    }
    [result setObject:cables forKey:@"cables"];
    
    
    return [NSDictionary dictionaryWithDictionary:result];
}

-(BOOL)buildFromDictionary:(NSDictionary*)dictionary {

    [self removeAll];
    
    BOOL success = YES;
    
    NSDictionary *modulesDictionaries = [dictionary objectForKey:@"modules"];
    
    NSLog(@"Restoring %lu modules", (unsigned long)[[modulesDictionaries allKeys] count]);
    
    for (NSString *moduleIdentifier in [modulesDictionaries allKeys]) {
        NSDictionary *moduleDictionary = [modulesDictionaries objectForKey:moduleIdentifier];
        CGPoint moduleCenter = [[moduleDictionary objectForKey:@"center"] CGPointValue];
        ModuleDescription *moduleDescription = [[ModuleCatalog sharedCatalog] moduleWithIdentifier:[moduleDictionary objectForKey:@"id"]];
        if (moduleDescription) {
            ModuleView *moduleView;
            if ((moduleView = [self addViewForModule:moduleDescription atPoint:moduleCenter identifier:moduleIdentifier])) {
                // Set parameters
                [moduleView setParametersFromDictionary:[moduleDictionary objectForKey:@"params"]];
            } else {
                success = NO;
            }
        } else {
            success = NO;
        }
    }
    
    NSArray *cablesArray = [dictionary objectForKey:@"cables"];
    
    for (NSDictionary *thisCable in cablesArray) {
        ModuleView *outModule = [self moduleWithIdentifier:[thisCable objectForKey:@"outputModule"]];
        ModuleView *inModule = [self moduleWithIdentifier:[thisCable objectForKey:@"inputModule"]];
        if (outModule && inModule) {
            ConnectorView *outConnector = [outModule connectorForName:[thisCable objectForKey:@"outputConnection"]];
            ConnectorView *inConnector = [inModule connectorForName:[thisCable objectForKey:@"inputConnection"]];
            if (outConnector && inConnector) {
                if ([self connectorView:outConnector connectWith:inConnector]) {
                    [self addCableFrom:outConnector to:inConnector withColour:[thisCable objectForKey:@"colour"]];
                } else {
                    success = NO;
                }
            } else {
                success = NO;
            }
        }
    }
    
    return success;
}

-(ModuleView*)moduleWithIdentifier:(NSString*)identifier {
    
    if ([identifier isEqualToString:@"Master"]) {
        return self.masterModuleView;
    } else {
        __block ModuleView *result = nil;
        
        [self.moduleViews enumerateKeysAndObjectsUsingBlock:^(NSString *key, ModuleView *obj, BOOL *stop) {
            if ([key isEqualToString:identifier]) {
                result = obj;
                *stop = YES;
            }
        }];
        
        return result;
    }
}

-(void)removeAll {
    NSLog(@"Removing all modules");
    
    for (NSString *thisModuleIdentifier in [self.moduleViews allKeys]) {
        ModuleView *moduleView = [self.moduleViews objectForKey:thisModuleIdentifier];
        [moduleView trash];
    }
    
    [self.moduleViews removeAllObjects];
    
    [self.cables removeAllObjects];
    [self.cableLayer setNeedsDisplay];
    
    for (NSUInteger i = 0; i < 256; i++) {
        for (NSUInteger j = 0; j < 256; j++) {
            cellOccupied[i][j] = NO;
        }
    }
    
    [[[COLAudioEnvironment sharedEnvironment] keyboardComponent] allNotesOff];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self;
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



@end