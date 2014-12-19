//
//  TextureManager.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextureManager.h"
#import "GameNode.h"

static TextureManager *sharedTexture=nil;

@interface TextureManager (Private)
-(void)loadAllTextures;
-(void)loadAllAnimations;
@end

@implementation TextureManager

@synthesize allTextures,vehicleTextureArray,batchTextures,animations;

-(id)init{
    if ((self=[super init])) {
        appDelegate=(AppController*)[[UIApplication sharedApplication] delegate];
        self.allTextures=[[NSMutableDictionary alloc] init];
        self.batchTextures=[[NSMutableDictionary alloc] init];
        self.animations=[[NSMutableDictionary alloc] init];
        self.vehicleTextureArray=[[NSMutableArray alloc] init];
        [self loadAllTextures];
        [self loadAllAnimations];
    }
    return self;
}

+(id)sharedTextureManager{
    if (sharedTexture==nil) {
        sharedTexture=[[TextureManager alloc] init];
    }
    return sharedTexture;
}

-(void)loadAllTextures{
    //vehicle textures
    CCTexture *bikeTexture=[CCTexture textureWithFile:@"bike.png"];
    [self.allTextures setObject:bikeTexture forKey:@"bikeTexture"];
    
    [self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"car1.png"]];
    [self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"car2.png"]];
    [self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"car3.png"]];
    //[self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"truck1.png"]];
    [self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"truck2.png"]];
    [self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"mud-tuck.png"]];
    [self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"ambulance.png"]];
    [self.vehicleTextureArray addObject:[CCTexture textureWithFile:@"school-bus.png"]];
    
    //[self.allTextures setObject:vTexture forKey:@"car1Texture"];
    //[self.allTextures setObject:[CCTexture textureWithFile:@"car2.png"] forKey:@"car2Texture"];
    
    //road textures
    CCTexture *roadTexture=[CCTexture textureWithFile:@"road-back.png"];
    [self.allTextures setObject:roadTexture forKey:@"roadTexture"];
    
    [self.allTextures setObject:[CCTexture textureWithFile:@"sidebarleft.png"] forKey:@"sidebarleft"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"sidebarright.png"] forKey:@"sidebarright"];
    
    [self.allTextures setObject:[CCTexture textureWithFile:@"side-stripe-left.png"] forKey:@"side-stripe-left"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"side-stripe-right.png"] forKey:@"side-stripe-right"];
    
    CCTexture *stripe=[CCTexture textureWithFile:@"stripe3.png"];
    [self.allTextures setObject:stripe forKey:@"stripe1Texture"];
    
    //CCTexture *overlay=[CCTexture textureWithFile:@"overlay.png"];
    //[self.allTextures setObject:overlay forKey:@"overlayTexture"];
    
    [self.allTextures setObject:[CCTexture textureWithFile:@"tree.png"] forKey:@"treeTexture"];
    
    //coin texture
    [self.allTextures setObject:[CCTexture textureWithFile:@"biker-point.png"] forKey:@"biker-point"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"biker-point-double.png"] forKey:@"biker-point-double"];
    
    //main menu back texture
    CCTexture *menuBack=[CCTexture textureWithFile:@"mainMenuBack.png"];
    [self.allTextures setObject:menuBack forKey:@"mainMenuBackTexture"];
    
    
    //buttons textures
    //CCTexture *customizeBTN=[CCTexture textureWithFile:@"customize.png"];
    //[self.allTextures setObject:customizeBTN forKey:@"customizeBTNTexture"];
    
    [self.allTextures setObject:[CCTexture textureWithFile:@"gc.png"] forKey:@"gcBTNTexture"];
    
    //[self.allTextures setObject:[CCTexture textureWithFile:@"highscore.png"] forKey:@"highScoreBTNTexture"];
    
    //[self.allTextures setObject:[CCTexture textureWithFile:@"play.png"] forKey:@"playBTNTexture"];
    
    [self.allTextures setObject:[CCTexture textureWithFile:@"ride.png"] forKey:@"rideBTNTexture"];
    
    [self.allTextures setObject:[CCTexture textureWithFile:@"store.png"] forKey:@"storeBTNTexture"];
    //[self.allTextures setObject:[CCTexture textureWithFile:@"btn-bg-glow.png"] forKey:@"storeBTNglow"];
    
    //gameNode menubutton Textures
    //[self.allTextures setObject:[CCTexture textureWithFile:@"button-home.png"] forKey:@"button-home"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"button-pause.png"] forKey:@"button-pause"];
    //[self.allTextures setObject:[CCTexture textureWithFile:@"button-play.png"] forKey:@"button-play"];
    //[self.allTextures setObject:[CCTexture textureWithFile:@"button-replay.png"] forKey:@"button-replay"];
    
    //powerUps textures
    [self.allTextures setObject:[CCTexture textureWithFile:@"pu-invincibility.png"] forKey:@"pu-invincibility"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"pu-magnet.png"] forKey:@"pu-magnet"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"pu-multiplier.png"] forKey:@"pu-multiplier"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"pu-shooter.png"] forKey:@"pu-shooter"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"pu-nos.png"] forKey:@"pu-nos"];
    
    [self.allTextures setObject:[CCTexture textureWithFile:@"superspeed.png"] forKey:@"superspeed"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"superspeed2x.png"] forKey:@"superspeed2x"];
    
    //meter textures
    [self.allTextures setObject:[CCTexture textureWithFile:@"meter.png"] forKey:@"meter"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"meter-arrow.png"] forKey:@"meter-arrow"];
    //score bar textures
    [self.allTextures setObject:[CCTexture textureWithFile:@"coin-bar.png"] forKey:@"coin-bar"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"score-bar.png"] forKey:@"score-bar"];
    
    //batchTextures
    [self.batchTextures setObject:[CCTexture textureWithFile:@"explosion.png"] forKey:@"explosion"];
    
    //audio Button Textures
    [self.allTextures setObject:[CCTexture textureWithFile:@"music-on.png"] forKey:@"music-on"];
    [self.allTextures setObject:[CCTexture textureWithFile:@"music-off.png"] forKey:@"music-off"];
}

-(void)loadAllAnimations{
    NSMutableArray *spriteFrames=[NSMutableArray array];
    CCSpriteFrame *spriteFrame;
    
    CCTexture *batchTexture=[self.batchTextures objectForKey:@"explosion"];
    
    CGSize frameSize=CGSizeMake(batchTexture.contentSize.width/EXPLOSIONXFRAMES, batchTexture.contentSize.height/EXPLOSIONYFRAMES);
    
    for (int i=0; i<(EXPLOSIONXFRAMES*EXPLOSIONYFRAMES); i++) {
        spriteFrame=[CCSpriteFrame frameWithTexture:batchTexture rect:CGRectMake((i%EXPLOSIONXFRAMES)*frameSize.width, (i/EXPLOSIONYFRAMES)*frameSize.height, frameSize.width, frameSize.height)];
        [spriteFrames addObject:spriteFrame];
    }
    
    CCAnimation *explosionAnim=[CCAnimation animationWithFrames:spriteFrames delay:0.05f];
    [[CCAnimationCache sharedAnimationCache] addAnimation:explosionAnim name:@"explosionAnim"];
    
    [spriteFrames removeAllObjects];
    spriteFrames=nil;
}

-(void)dealloc{
    [sharedTexture release];
    [self.allTextures removeAllObjects];
    self.allTextures=nil;
    [self.vehicleTextureArray removeAllObjects];
    self.vehicleTextureArray=nil;
    [self.batchTextures removeAllObjects];
    self.batchTextures=nil;
    [self.animations removeAllObjects];
    self.animations=nil;
    
    [super dealloc];
}

@end
