//
//  Obstacles.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Obstacles.h"
#import "TextureManager.h"
#import "GameNode.h"

@interface Obstacles (Private)
+(CCTexture*)obstacleTexture;
-(void)setAliasTexParametersForObstacle;
-(void)changeTexture;
-(CGPoint)getLaneChangeDest;
@end

@implementation Obstacles

@synthesize isShooted,isToChangeLane,laneChangeDir,initialPosition,laneChangeDest,vehicleSpeed,laneChangeSpeed;

-(id)initWithTexture:(CCTexture *)texture{
    if (self=[super initWithTexture:texture]) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] winSize];
        
        self.anchorPoint=ccp(0.5f, 1.0f);
    }
    return self;
}

+(id)generateObstacleWithAliasTextureParam{
    Obstacles *obstacle=[[self alloc] initWithTexture:[Obstacles obstacleTexture]];
    [obstacle setAliasTexParametersForObstacle];
    return obstacle;
}

-(void)setAliasTexParametersForObstacle{
    [[self texture] setAliasTexParameters];
}

-(void)changeTexture{
    CCTexture *newTexture=[Obstacles obstacleTexture];
    [self setDisplayFrame:[CCSpriteFrame frameWithTexture:newTexture rect:CGRectMake(0.0f, 0.0f, newTexture.contentSize.width, newTexture.contentSize.height)]];
}

-(float)getXTransition:(float)yPos currentPos:(CGPoint)crntPos{
    //    NSLog(@"crntpos--->%f,%f,%f yps-->%f",MAXPOINT,crntPos.x,crntPos.y,yPos);
    float YDiff=MAXPOINT-crntPos.y;
    float XDiff=winSize.width/2-crntPos.x;
    float dltX;
    if (XDiff!=0) {
        float grad=YDiff/XDiff;
        dltX=crntPos.x-((crntPos.y-yPos)/grad);
    }
    else
        dltX=winSize.width/2;
    //    NSLog(@"xdif-->%f,ydiff-->%f",XDiff,YDiff);
    
    return dltX;
}

-(CGPoint)getLaneChangeDest{
    float destY,destX;
    destY=(winSize.height*(1.0f/5.0f))*(float)(arc4random()%4);
    if (self.position.x!=winSize.width/2.0f) {
        destX=[self getXTransition:destY currentPos:ccp(winSize.width/2.0f, 0.0f)];
        if (self.position.x>winSize.width/2.0f) {
            self.laneChangeDir=-1;
        }
        else
            self.laneChangeDir=+1;
    }
    else{
        int dir=arc4random()%2;
        if (dir==0) {//dir --->
            destX=[self getXTransition:destY-(self.vehicleSpeed*VEHICLELANECHANGESPEED) currentPos:ccp((winSize.width/2.0f)+120.0f, 0.0f)];
            self.laneChangeDir=+1;
        }
        else{//dir <---
            destX=[self getXTransition:destY-(self.vehicleSpeed*VEHICLELANECHANGESPEED) currentPos:ccp((winSize.width/2.0f)-120.0f, 0.0f)];
            self.laneChangeDir=-1;
        }
    }
    return CGPointMake(destX, destY);
}

-(void)resetProperties{
    self.isShooted=NO;
    self.position=self.initialPosition;
    self.vehicleSpeed=(INITIALSPEED/10.0f)*(1.5f+(float)(arc4random()%3));
    
    int selection=arc4random()%2;
    if (selection==0) {
        isToChangeLane=NO;
    }
    else
        isToChangeLane=YES;
    
    if (isToChangeLane==YES) {
        self.laneChangeDest=[self getLaneChangeDest];
        self.laneChangeSpeed=(self.laneChangeDir*(fabsf(self.laneChangeDest.x-self.position.x)/VEHICLELANECHANGESPEED));
//        NSLog(@"is to change lane speed->%f",self.laneChangeSpeed);
    }
    else{
//        NSLog(@"not to change lane");
        self.laneChangeDest=ccp(0.0f, 0.0f);
        self.laneChangeSpeed=0.0f;
    }
    
    [self changeTexture];
}

+(CCTexture*)obstacleTexture{
    int indxCount=[[[TextureManager sharedTextureManager] vehicleTextureArray] count];
    int targetIndx=arc4random()%indxCount;
    return [[[TextureManager sharedTextureManager] vehicleTextureArray] objectAtIndex:targetIndx];
}

-(void)dealloc{
    [super dealloc];
}

@end
