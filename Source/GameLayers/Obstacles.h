//
//  Obstacles.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppController.h"

@interface Obstacles : CCSprite {
@private
    AppController *appDelegate;
    CGSize winSize;
}

@property (nonatomic) BOOL isShooted,isToChangeLane;
@property (nonatomic) int laneChangeDir;
@property (nonatomic) CGPoint initialPosition,laneChangeDest;
@property (nonatomic) float vehicleSpeed,laneChangeSpeed;

+(id)generateObstacleWithAliasTextureParam;
-(void)resetProperties;
@end
