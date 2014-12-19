//
//  GameMenu.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppController.h"
#import "RVRPowerUpsAndPurchasesStore.h"

@class GameCenterDelegate;

#define NOOFBTNS 3

@interface GameMenu : CCLayer<ControllerMenu> {
@private
    AppController *appDelegate;
    CGSize winSize;
    
    NSMutableArray *menuButtons;
    NSMutableArray *btnGlows;
    NSInteger clickedButtonTag;
    
    CCSprite *clickedBtnRefKeeper;
    CCSprite *audioBtn;
    BOOL audioBtnAdded;
    
    GameCenterDelegate *gcDelegate;
}

+(CCScene *) scene;
-(void)uiViewAnimaitonDidFinish;

@end
