//
//  ComponentTrayCollectionViewCell.h
//  ColaApp
//
//  Created by Chris on 04/03/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComponentTrayView.h"

@interface ComponentTrayCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) ComponentTrayView *componentTrayView;
@property (nonatomic, strong) UIImageView *thumbnailImageView;

@end
