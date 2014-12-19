//
//  PauseOrGameOverMenu.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"

@class AppController;

@protocol PauseOrGameOverMenuBtnClickDelegate <NSObject>
-(void)buttonClickedWithTag:(int)tag;
@end

@interface PauseOrGameOverMenu : RootViewController{
@private
    AppController *appDelegate;
    CGSize winSize;
    
    UIView *pauseMenuView;
    UIView *gameOverMenuView;
    
    NSInteger btnClickedTag;
}

+(id)menu;
-(void)pauseMenu;
-(void)gameOverMenu;

-(void)uiViewAnimaitonDidFinish:(id)sender;

@property (nonatomic,readwrite,retain) id<PauseOrGameOverMenuBtnClickDelegate> delegate;
@property (nonatomic) BOOL reqSent;

@end
