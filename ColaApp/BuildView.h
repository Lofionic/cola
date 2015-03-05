//
//  BuildView.h
//  ColaApp
//
//  Created by Chris on 05/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildViewCellPath : NSObject

-(instancetype)initWithColumn:(NSInteger)column Row:(NSInteger)row;

@property (nonatomic) NSInteger column;
@property (nonatomic) NSInteger row;

@end

@interface BuildView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSSet *highlightedCellSet;

-(instancetype)initWithColumns:(NSInteger)columns;

-(BuildViewCellPath*)cellPathForPoint:(CGPoint)point;

@end
