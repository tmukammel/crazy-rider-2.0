//
//  PowerUp.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PowerUp.h"
#import "AppDelegate.h"

@interface PowerUp (Private)
+(CCTexture*)obstacleTexture;
-(void)setAliasTexParametersForObstacle;
-(void)changeTexture;
@end

@implementation PowerUp

@synthesize stringTag,inValidateNextDisableCall;

-(id)initWithTexture:(CCTexture *)texture{
    if ((self=[super initWithTexture:texture])) {
        appDelegate=(AppController*)[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] viewSize];
        
        self.anchorPoint=ccp(0.5f, 1.0f);
        self.visible=NO;
        [[self texture] setAntialiased:NO];
    }
    return self;
}

+(id)generatePowerUpWithTexture:(CCTexture *)texture{
    return [[self alloc] initWithTexture:texture];
}

-(void)resetProperties{
    
}

@end
