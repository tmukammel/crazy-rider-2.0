//
//  RVRCoin.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RVRCoin.h"
#import "TextureManager.h"
#import "GameNode.h"

@interface RVRCoin (Private)
+(CCTexture*)myTexture;
-(void)setAliasTexParametersForMe;
-(void)addRotationActionFor:(CCSprite*)target;
-(CCFiniteTimeAction*)getCollectionAction;
-(CCFiniteTimeAction*)getMagnetInducedCollectionAction;
-(void)hideAliasCoin:(CCSprite*)coin;
-(void)createAliasCoin;
@end

@implementation RVRCoin

@synthesize aliasCoin,multiplier;

-(id)initWithTexture:(CCTexture *)texture{
    self=[super initWithTexture:texture];
    
    if (self) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] winSize];
        
        self.anchorPoint=ccp(0.5f, 1.0f);
        [self addRotationActionFor:self];
        [self createAliasCoin];
    }
    
    return self;
}

+(id)generateCoin{
    return [[[self alloc] initWithTexture:[RVRCoin myTexture]] autorelease];
}

+(id)generateCoinWithAliasTexParameters{
    RVRCoin *coin=[[[self alloc] initWithTexture:[RVRCoin myTexture]] autorelease];
    [coin setAliasTexParametersForMe];
    return coin;
}

-(void)setAliasTexParametersForMe{
    [[self texture] setAliasTexParameters];
}

+(CCTexture*)myTexture{
    return [((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"biker-point"];
}

-(void)setDoubleValueTexture{
    [self setTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"biker-point-double"]];
    [self setAliasTexParametersForMe];
    self.multiplier=2;
    [aliasCoin setTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"biker-point-double"]];
}

-(void)resetToOriginalTexture{
    [self setTexture:[RVRCoin myTexture]];
    [self setAliasTexParametersForMe];
    self.multiplier=1;
    [aliasCoin setTexture:[RVRCoin myTexture]];
}

-(void)flipCoin:(CCSprite*)target{
    if (target.flipX==YES) {
        target.flipX=NO;
    }
    else
        target.flipX=YES;
}

-(void)addRotationActionFor:(CCSprite*)target{
    CCScaleTo *scaleTo=[CCScaleTo actionWithDuration:0.5f scaleX:0.1f scaleY:1.0];
    CCCallFuncO *calFlipX=[CCCallFuncO actionWithTarget:self selector:@selector(flipCoin:) object:target];
    CCScaleTo *scaleBack=[CCScaleTo actionWithDuration:0.5f scaleX:1.0f scaleY:1.0];
    CCSequence *sequence=[CCSequence actions:scaleTo,calFlipX,scaleBack, nil];
    CCRepeatForever *repeatForever=[CCRepeatForever actionWithAction:sequence];
    [[CCActionManager sharedManager] addAction:repeatForever target:target paused:YES];
}

-(void)createAliasCoin{
    aliasCoin=[CCSprite spriteWithTexture:[self texture]];
    aliasCoin.visible=NO;
    [appDelegate.gNode addChild:aliasCoin];
}

-(CCFiniteTimeAction*)getCollectionAction{
    ccBezierConfig myBezierConfig;
    myBezierConfig.controlPoint_1=CGPointMake(self.position.x+50, self.position.y);
    myBezierConfig.controlPoint_2=CGPointMake(self.position.x, self.position.y+50);
    myBezierConfig.endPosition=CGPointMake(winSize.width, winSize.height);
    
    CCBezierTo *myBezierPath=[CCBezierTo actionWithDuration:1.0f bezier:myBezierConfig];
    
    return myBezierPath;
}

-(void)hideAliasCoin:(CCSprite *)coin{
    [[CCActionManager sharedManager] removeAllActionsFromTarget:coin];
    aliasCoin.visible=NO;
    [appDelegate.gNode.collectedBikerPoints removeObject:self];
//    NSLog(@"collected count--->%d",[appDelegate.gNode.collectedBikerPoints count]);
}

-(void)performCoinCollectionAndAnimation{
    aliasCoin.position=self.position;
    aliasCoin.visible=YES;
    
    [self addRotationActionFor:aliasCoin];
    [aliasCoin resumeSchedulerAndActions];
    
    self.visible=NO;
    [self resetToMyOriginalPos];
    
    CCCallFuncO *hideAliasCoin=[CCCallFuncO actionWithTarget:self selector:@selector(hideAliasCoin:) object:aliasCoin];
    CCSequence *sequence=[CCSequence actions:[self getCollectionAction], hideAliasCoin, nil];
    [aliasCoin runAction:sequence];
}

-(CCFiniteTimeAction*)getMagnetInducedCollectionAction{
    GameNode *gameNode=appDelegate.gNode;
    
    float xShift=gameNode.bikeSprite.contentSize.height*sinf((PI/180.0f)*gameNode.bikeSprite.rotation);
    float yShift=gameNode.bikeSprite.contentSize.height*cosf((PI/180.0f)*gameNode.bikeSprite.rotation);
    
    CGPoint destPoint=CGPointMake(gameNode.bikeSprite.position.x+xShift, gameNode.bikeSprite.position.y+yShift);
    
    float actionDuration=0.5f;///winSize.height)*ccpDistance(destPoint, aliasCoin.position);
    
    float vTargetYShift=(gameNode.bSpeed*actionDuration);
    
    if (gameNode.isBikeAccelerating>0)
        vTargetYShift+=(0.5f*ACCELERATION*pow(actionDuration, 2));
    
    else if(gameNode.isBikeAccelerating<0)
        vTargetYShift+=(0.5f*RETARDATION*pow(actionDuration, 2));
    
    float controlP2XShift=(gameNode.bikeSprite.position.x-aliasCoin.position.x)*(30.0f/145.0f);//145->half of max xShift!
    float controlP2YShift=fabsf(controlP2XShift);
    
    ccBezierConfig myBezierConfig;
    myBezierConfig.controlPoint_1=CGPointMake(aliasCoin.position.x, aliasCoin.position.y-(controlP2YShift/2.0f));
    myBezierConfig.controlPoint_2=CGPointMake(aliasCoin.position.x-controlP2XShift, aliasCoin.position.y-controlP2YShift);
    myBezierConfig.endPosition=CGPointMake(destPoint.x, destPoint.y+vTargetYShift);
    
    CCBezierTo *myBezierPath=[CCBezierTo actionWithDuration:actionDuration bezier:myBezierConfig];
    
    return myBezierPath;
}

-(void)performMagnetInducedCollectionAnimation{
    aliasCoin.position=self.position;
    aliasCoin.visible=YES;
    
    //[self addRotationActionFor:aliasCoin];
    //[aliasCoin resumeSchedulerAndActions];
    
    self.visible=NO;
    [self resetToMyOriginalPos];
    
    CCCallFuncO *hideAliasCoin=[CCCallFuncO actionWithTarget:self selector:@selector(hideAliasCoin:) object:aliasCoin];
    CCSequence *sequence=[CCSequence actions:[self getMagnetInducedCollectionAction], hideAliasCoin, nil];
    [aliasCoin runAction:sequence];
}

-(void)setMyOriginalPosition{
    if (!isMyOriginalPosSet) {
        isMyOriginalPosSet=YES;
        myOriginalPostion=self.position;
    }
}

-(BOOL)resetToMyOriginalPos{
    if (isMyOriginalPosSet) {
        self.position=myOriginalPostion;
        return YES;
    }
    else
        return NO;
}

-(void)dealloc{
    
    [super dealloc];
}

@end
