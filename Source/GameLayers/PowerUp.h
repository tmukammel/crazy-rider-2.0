//
//  PowerUp.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class AppController;

@interface PowerUp : CCSprite {
@private
    AppController *appDelegate;
    CGSize winSize;
}

@property (nonatomic,readwrite,retain) NSString *stringTag;
@property (nonatomic) BOOL inValidateNextDisableCall;

+(id)generatePowerUpWithTexture:(CCTexture*)texture;
-(void)resetProperties;

@end
