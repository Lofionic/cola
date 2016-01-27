//
//  ModuleSubview.h
//  ColaApp
//
//  Created by Chris on 27/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ColaLib/COLAudioEnvironment.h>
#import "ModuleDescription.h"

@interface ModuleSubview : UIView

// Factory method
+ (ModuleSubview*)subviewForComponent:(CCOLComponentAddress)component description:(SubviewDescription*)description;

// Designated initializer
- (instancetype)initWithComponent:(CCOLComponentAddress)component description:(SubviewDescription*)description;

@end
