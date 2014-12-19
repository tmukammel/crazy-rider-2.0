//
//  TextureManager.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AppDelegate.h"

#define EXPLOSIONXFRAMES 3
#define EXPLOSIONYFRAMES 3
#define NOOFEXPLOSIONSPRITES 3

@interface TextureManager : NSObject{
@private
    AppController *appDelegate;
}

@property (nonatomic,readwrite,retain) NSMutableDictionary *allTextures,*batchTextures,*animations;
@property (nonatomic,readwrite,retain) NSMutableArray *vehicleTextureArray;

+(id)sharedTextureManager;

@end
