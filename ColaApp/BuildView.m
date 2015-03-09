//
//  BuildView.m
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//
#import "defines.h"
#import "BuildView.h"

@interface BuildView () {
    bool cellOccupied[256][256];
}

@property (nonatomic) CGSize cellSize;
@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger columns;

@property (nonatomic, strong) NSMutableSet *occupiedCells;

@end

@implementation BuildViewCellPath

-(instancetype)initWithColumn:(NSInteger)column Row:(NSInteger)row {
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
        
        self.contentSize = CGSizeMake(
                                      self.columns * self.cellSize.width,
                                      self.rows * self.cellSize.height
                                      );

        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0.05 alpha:1]];
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        
        self.occupiedCells = [[NSMutableSet alloc] initWithCapacity:self.columns * self.rows];
        
        [self setDelegate:self];
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
        for (BuildViewCellPath* thisCellPath in self.highlightedCellSet) {
            CGFloat xHighlight = thisCellPath.column * self.cellSize.width;
            CGFloat yHighlight = thisCellPath.row * self.cellSize.height;
            CGRect highlightRect = CGRectMake(xHighlight, yHighlight, self.cellSize.width, self.cellSize.height);
            CGContextAddRect(ctx, highlightRect);
        }
        CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextFillPath(ctx);
    }
    
    // Draw grid
    CGContextSetStrokeColorWithColor(ctx, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 0.5);
    
    CGFloat yPosition = self.cellSize.height;
    do {
        CGContextMoveToPoint(ctx, 0, yPosition);
        CGContextAddLineToPoint(ctx, self.contentSize.width, yPosition);
        yPosition += self.cellSize.height;
    } while (yPosition < self.contentSize.height);
    
    CGFloat xPosition = self.cellSize.width;
    do {
        CGContextMoveToPoint(ctx, xPosition, 0);
        CGContextAddLineToPoint(ctx, xPosition, self.contentSize.height);
        xPosition += self.cellSize.width;
    } while (xPosition < self.contentSize.width);
    
    CGContextStrokePath(ctx);
}

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point {
    // Return the cell path for a point within the view's coordinate space
    if (point.x >= 0 && point.x <= self.contentSize.width &&
        point.y >= 0 && point.y <= self.contentSize.height) {
    
        NSInteger column = point.x / self.cellSize.width;
        NSInteger row = point.y / self.cellSize.height;
        
        return [[BuildViewCellPath alloc] initWithColumn:column Row:row];
    } else {
        return nil;
    }
}

-(NSSet*)cellPathsForComponentOfWidth:(NSInteger)width height:(NSInteger)height center:(CGPoint)center {
    
    CGPoint minPoint = CGPointMake(
                                   center.x - ((width - 1) * self.cellSize.width) / 2.0,
                                   center.y - ((height - 1) * self.cellSize.height) / 2.0
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

-(CGRect)getRectForCellSet:(NSSet*)cellSet {
    
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
    
    CGRect result = CGRectMake(left * self.cellSize.width, top * self.cellSize.height, (right - left + 1) * self.cellSize.width, (bottom - top + 1) * self.cellSize.height);
    return result;
}

-(UIView*)addViewForComponent:(ComponentDescription)componentDescription atPoint:(CGPoint)point {
    NSSet *cellSet = [self cellPathsForComponentOfWidth:componentDescription.width height:componentDescription.height center:point];
    if (cellSet) {
        CGRect newFrame = [self getRectForCellSet:cellSet];
        
        UIView *newView = [[UIView alloc] initWithFrame:newFrame];
        [newView setBackgroundColor:[UIColor whiteColor]];
        
        [self addSubview:newView];
        
        // Add cells to occupied
        [cellSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            BuildViewCellPath *cellPath = (BuildViewCellPath*)obj;
            cellOccupied[cellPath.row][cellPath.column] = TRUE;
        }];
        
        return newView;
    }
    return nil;
}


@end
