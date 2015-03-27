//
//  ComponentTrayCollectionViewCell.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComponentDescription;
@class ComponentShelfView;
@interface ComponentShelfCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) ComponentShelfView *componentTrayView;
@property (nonatomic, weak) ComponentDescription *componentDescription;
@property (nonatomic, strong) UIImageView *thumbnailImageView;

@end
