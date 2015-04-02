//
//  ComponentTrayCollectionViewCell.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModuleDescription;
@class ComponentShelfView;
@interface ComponentShelfCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, weak) ComponentShelfView *componentShelf;
@property (nonatomic, weak) ModuleDescription *moduleDescription;

@end
