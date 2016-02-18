//
//  ModuleSubview.m
//  ColaApp
//
//  Created by Chris on 27/01/2016.
//  Copyright © 2016 Chris Rivers. All rights reserved.
//

#import "ModuleSubview.h"
#import "SequencerSubview.h"

@interface ModuleSubview()

@property (nonatomic) CCOLComponentAddress          component;
@property (nonatomic, strong) SubviewDescription    *subviewDescription;

@end

@implementation ModuleSubview

+ (ModuleSubview *)subviewForComponent:(CCOLComponentAddress)component description:(SubviewDescription *)subviewDescription {
    
    ModuleSubview *result = nil;

    if ([subviewDescription.type isEqualToString:@"sequencer"]) {
        result = [[SequencerSubview alloc] initWithComponent:component description:subviewDescription];
    }
    
    return result;
}

- (instancetype)initWithComponent:(CCOLComponentAddress)component description:(SubviewDescription*)subviewDescription
{
    CGRect frame = CGRectMake(subviewDescription.location.x, subviewDescription.location.y, subviewDescription.size.width, subviewDescription.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        self.component = component;
        self.subviewDescription = subviewDescription;
    }
    
    return self;
}

@end
