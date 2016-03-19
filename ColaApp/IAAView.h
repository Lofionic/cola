//
//  IAAView.h
//  ColaApp
//
//  Created by Chris on 31/05/2015.
//  Copyright (c) 2015 Chris Rivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAAView;
@protocol IAAViewDelegate <NSObject>

-(UIImage*)getIAAHostImageForIAAView:(IAAView*)iaaView;
-(bool)isIAAHostPlayingForIAAView:(IAAView*)iaaView;
-(bool)isIAAHostRecordingForIAAView:(IAAView*)iaaView;

@optional
-(void)iaaViewDidTapPlay:(IAAView*)iaaView;
-(void)iaaViewdidTapRewind:(IAAView*)iaaView;
-(void)iaaViewDidTapRecord:(IAAView*)iaaView;
-(void)iaaViewDidTapHostImage:(IAAView*)iaaView;

@end

@interface IAAView : UIView

@property (nonatomic, weak) NSObject<IAAViewDelegate>* delegate;

-(void)updateContents;

@end
