//
//  RVRCoin.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppController.h"

@interface RVRCoin : CCSprite {
@private
    AppController *appDelegate;
    CGSize winSize;
    
    CGPoint myOriginalPostion;
    BOOL isMyOriginalPosSet;
}

+(id)generateCoinWithAliasTexParameters;
+(id)generateCoin;

-(void)setMyOriginalPosition;
-(BOOL)resetToMyOriginalPos;
-(void)performCoinCollectionAndAnimation;
-(void)performMagnetInducedCollectionAnimation;
-(void)setDoubleValueTexture;
-(void)resetToOriginalTexture;

@property (nonatomic,readwrite,retain) CCSprite *aliasCoin;
@property (nonatomic) int multiplier;

@end
