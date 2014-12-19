//
//  LoadingView.h
//  ITIW
//
//  Created by itiw on 1/4/11.
//  Copyright 2011 ITIW. All rights reserved.
//

#import "cocos2d.h"
#import <UIKit/UIKit.h>

@protocol LoadingViewDelegate <NSObject>
- (void)loadingDidCanceled;
@end

@interface LoadingView : UIView
{
    UILabel *loadingLabel;
    UIActivityIndicatorView *activityIndicatorView;
    id <LoadingViewDelegate> delegate;
}

@property (nonatomic, assign) id <LoadingViewDelegate> delegate;
+ (id)loadingViewInView:(UIView *)aSuperview;
- (void)loadElements;
- (void)removeView;
- (void)loadCrossButton;
@end