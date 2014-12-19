//
//  BikeNode.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BikeLayer.h"
#import "TextureManager.h"

static BikeLayer *bike;

@implementation BikeLayer

@synthesize bikeSprite;

-(id)init{
    if ((self=[super init])) {
        //self.isAccelerometerEnabled=YES;
        
        CGSize winSize=[[CCDirector sharedDirector] winSize];
        bikeSprite=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"bikeTexture"]];
        bikeSprite.anchorPoint=ccp(0.5f, 0.0f);
        bikeSprite.position=ccp(winSize.width/2, 0.0f);
        [self addChild:bikeSprite];
    }
    return self;
}

+(id)bike{
    if (bike==nil) {
        bike=[[BikeLayer alloc] init];
    }
    return bike;
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{

#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
    
    static float prevX=0, prevY=0;
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
    
    CCRotateTo *rotateTo=[CCRotateTo actionWithDuration:0.1 angle:-(accelY*45)];
    [self.bikeSprite runAction:rotateTo];
    
    /*
    float absRotation;
    if (((BikeLayer*)[BikeLayer bike]).bikeSprite.rotation<0)
        absRotation=-1*((BikeLayer*)[BikeLayer bike]).bikeSprite.rotation;
    else
        absRotation=((BikeLayer*)[BikeLayer bike]).bikeSprite.rotation;
    
    absRotation*=3;
    
    if (appDelegate.bikeReference.position.x+(-accelY*absRotation)>120 && appDelegate.bikeReference.position.x+(-accelY*absRotation)<360) {
        
        CCMoveBy *moveBy=[CCMoveBy actionWithDuration:0.1 position:ccp(-accelY*absRotation, appDelegate.bikeReference.position.y)];
        
        [appDelegate.bikeReference runAction:moveBy];
    }
    else if(appDelegate.bikeReference.position.x>120 && accelY>=0){
        CCMoveTo *moveBy=[CCMoveTo actionWithDuration:0.1 position:ccp(120.1f, appDelegate.bikeReference.position.y)];
        
        [appDelegate.bikeReference runAction:moveBy];
    }
    else if(appDelegate.bikeReference.position.x<360 && accelY<0){
        CCMoveTo *moveBy=[CCMoveTo actionWithDuration:0.1 position:ccp(359.9f, appDelegate.bikeReference.position.y)];
        
        [appDelegate.bikeReference runAction:moveBy];
    }
    */
}

@end
