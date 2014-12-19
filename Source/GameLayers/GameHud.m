//
//  GameHud.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameHud.h"
#import "TextureManager.h"

@interface GameHud (Private)
-(void)addSepeedometer;
-(void)addScoreBars;
@end

@implementation GameHud

@synthesize coinsLabel,vDodgedLabel,speedLabel,distanceLabel,meterArrow;

-(id)init{
    if ((self=[super init])) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] winSize];
        appDelegate.gHud=self;
        
        //[self addSepeedometer];
        [self addScoreBars];
        
        coinsLabel=[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",appDelegate.databaseManager.userData.uCoins] fontName:FONTNAME fontSize:FONTSIZE];
        coinsLabel.anchorPoint=ccp(1.0f, 1.0f);
        coinsLabel.position=ccp(winSize.width-2.0f, winSize.height);
        [self addChild:coinsLabel];
        /*
        vDodgedLabel=[CCLabelTTF labelWithString:@"V Dodged 0" fontName:FONTNAME fontSize:FONTSIZE];
        vDodgedLabel.anchorPoint=ccp(1.0f, 1.0f);
        vDodgedLabel.position=ccp(winSize.width, winSize.height-coinsLabel.contentSize.height-20.0f);
        [self addChild:vDodgedLabel];
        */
        /*
        speedLabel=[CCLabelTTF labelWithString:@"70" fontName:FONTNAME fontSize:15.0];
        speedLabel.anchorPoint=ccp(0.5f, 0.5f);
        speedLabel.position=ccp(50.0f, winSize.height-67.0f);
        [self addChild:speedLabel z:101];
        */
        distanceLabel=[CCLabelTTF labelWithString:@"0  M" fontName:FONTNAME fontSize:FONTSIZE];
        distanceLabel.anchorPoint=ccp(1.0f, 1.0f);
        distanceLabel.position=ccp(/*winSize.width-*/90.0f, winSize.height/*-30.0f*/);
        [self addChild:distanceLabel];
    }
    return self;
}

-(void)addSepeedometer{
    CCSprite *meter=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"meter"]];
    meter.anchorPoint=ccp(0.5f, 0.5f);
    meter.position=ccp(meter.contentSize.width/2.0f, winSize.height-(meter.contentSize.height/2.0f));
    [self addChild:meter z:100];
    
    meterArrow=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"meter-arrow"]];
    meterArrow.anchorPoint=ccp(1.0f-(5.0f/meterArrow.contentSize.width), 0.5f);
    meterArrow.position=ccp(meter.contentSize.width/2.0f, meter.contentSize.height/2.0f);
    meterArrow.rotation=METERARROWINIROTCONST;
    [meter addChild:meterArrow];
}

-(void)addScoreBars{
    CCSprite *sprite=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"coin-bar"]];
    sprite.anchorPoint=ccp(1.0f, 1.0f);
    sprite.position=ccp(winSize.width, winSize.height);
    [self addChild:sprite];
    
    sprite=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"score-bar"]];
    sprite.anchorPoint=ccp(0.0f, 1.0f);
    sprite.position=ccp(/*winSize.width*/0.0f, winSize.height/*-sprite.contentSize.height-5.0f*/);
    [self addChild:sprite];
}

-(void)dealloc{
    [super dealloc];
}

@end
