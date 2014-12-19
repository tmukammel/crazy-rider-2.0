//
//  GameHud.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppController.h"

#define FONTSIZE 20.0F
#define FONTNAME @"MarkerFelt-Thin"

#define METERARROWINIROTCONST 55.0F
#define METERARROWROTATIONMAXADD 165.0F

@interface GameHud : CCNode {
@private
    AppController *appDelegate;
    CGSize winSize;
}

@property (nonatomic,readwrite,retain) CCLabelTTF *coinsLabel,*vDodgedLabel,*speedLabel,*distanceLabel;
@property (nonatomic,readwrite,retain) CCSprite *meterArrow;

@end
