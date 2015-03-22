//
//  BuildView.m
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "BuildView.h"

#import <ColaLib/ColaLib.h>

@interface BuildView () {
    bool cellOccupied[256][256];
}

@property (nonatomic) CGSize cellSize;
@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) NSUInteger rows;
@property (nonatomic) NSUInteger columns;

@property (nonatomic, strong) NSMutableSet *occupiedCells;

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

@implementation BuildView

-(instancetype)init {
    self = [super init];
    if (self) {
        self.columns = kBuildViewColumns;
        self.rows = kBuildViewRows;
        
        CGFloat columnWidth = kBuildViewWidth / self.columns;
        CGFloat rowHeight = columnWidth * (0.75);
        
        self.cellSize = CGSizeMake(columnWidth, rowHeight);
        self.headerHeight = 64;
        
        self.contentSize = CGSizeMake(
                                      self.columns * self.cellSize.width,
                                      (self.rows * self.cellSize.height) + self.headerHeight
                                      );

        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0.05 alpha:1]];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        
        self.occupiedCells = [[NSMutableSet alloc] initWithCapacity:self.columns * self.rows];
        
        [self setDelegate:self];
        
        // Add the Main Inputs
        COLComponentIO *mainIn = [[COLAudioContext globalContext] masterInputAtIndex:0];
        ConnectorView *mainInConnectorView = [[ConnectorView alloc] initWithComponentIO:mainIn];
        [mainInConnectorView setCenter:CGPointMake(40, self.headerHeight / 2.0)];
        [self addSubview:mainInConnectorView];
    }
    return self;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self;
}

@synthesize highlightedCellSet = _highlightedCellSet;

-(NSSet*)highlightedCellSet {
    return _highlightedCellSet;
}

-(void)setHighlightedCellSet:(NSSet *)highlightedCellSet {
    if (![_highlightedCellSet isEqualToSet:highlightedCellSet]) {
        // Highlighted cell set has changed
        _highlightedCellSet = highlightedCellSet;
        [self setNeedsDisplay];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Draw highlighed cell
    if (self.highlightedCellSet) {
        CGRect highlightRect = [self rectForCellSet:self.highlightedCellSet];
        highlightRect = CGRectInset(highlightRect, 2, 2);
        CGContextAddRect(ctx, highlightRect);
        CGContextSetStrokeColorWithColor(ctx, [[UIColor redColor] CGColor]);
        CGContextSetLineWidth(ctx, 4);
        CGContextStrokePath(ctx);
    }
    
    // Draw grid
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    
    CGFloat yPosition = self.headerHeight;
    do {
        CGContextMoveToPoint(ctx, 0, yPosition);
        CGContextAddLineToPoint(ctx, self.contentSize.width, yPosition);
        yPosition += self.cellSize.height;
    } while (yPosition < self.contentSize.height);
    
    CGFloat xPosition = self.cellSize.width;
    do {
        CGContextMoveToPoint(ctx, xPosition, self.headerHeight);
        CGContextAddLineToPoint(ctx, xPosition, self.contentSize.height);
        xPosition += self.cellSize.width;
    } while (xPosition < self.contentSize.width);
    
    CGContextStrokePath(ctx);
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

-(NSSet*)cellPathsForComponentOfWidth:(NSUInteger)width height:(NSUInteger)height center:(CGPoint)center {
    
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

-(UIView*)addViewForComponent:(ComponentDescription*)componentDescription atPoint:(CGPoint)point {
    NSSet *cellSet = [self cellPathsForComponentOfWidth:componentDescription.width height:componentDescription.height center:point];
    if (cellSet) {
        COLComponent *component = [[COLAudioEnvironment sharedEnvironment] createComponentOfType:componentDescription.type];
        
        if (component) {
            CGRect newFrame = [self rectForCellSet:cellSet];
            
            UIView *newView = [[UIView alloc] initWithFrame:newFrame];
            [newView setBackgroundColor:[UIColor whiteColor]];
            
            NSArray *connectors = [componentDescription connectors];
            for (ConnectorDescription *thisConnector in connectors) {
                
                COLComponentIO *componentIO = nil;
                if ([thisConnector.type isEqualToString:@"output"]) {
                    componentIO = [component outputNamed:thisConnector.connectionName];
                } else if ([thisConnector.type isEqualToString:@"input"]) {
                    componentIO = [component inputNamed:thisConnector.connectionName];
                }
                
                if (componentIO) {
                    ConnectorView *connectorView = [[ConnectorView alloc] initWithComponentIO:componentIO];
                    [connectorView setCenter:thisConnector.position];
                    [connectorView setDelegate:self];
                    [newView addSubview:connectorView];
                }
            }
            
            [self addSubview:newView];
            
            // Add cells to occupied
            [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
                cellOccupied[cellPath.row][cellPath.column] = TRUE;
            }];
            
            return newView;
        }
    }
    return nil;
}

-(COLComponent*)componentForCompomentDescription:(ComponentDescription*)componentDescription {
    COLComponent *result = [[COLAudioEnvironment sharedEnvironment] createComponentOfType:componentDescription.type];
    return result;
}

#pragma mark ConnectorView Delegate

-(void)connectorView:(ConnectorView *)connectorView didBeginDrag:(UIPanGestureRecognizer *)uigr {
    self.draggingConnector = connectorView;
}

-(void)connectorView:(ConnectorView *)connectorView didContinueDrag:(UIPanGestureRecognizer *)uigr {
    
}

-(void)connectorView:(ConnectorView *)connectorView didEndDrag:(UIPanGestureRecognizer *)uigr {
    UIView *hitView = [self hitTest:[uigr locationInView:self] withEvent:nil];
    
    if ([hitView isKindOfClass:[ConnectorView class]]) {
        [self connectorView:connectorView connectWith:(ConnectorView*)hitView];
    }
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

@end
