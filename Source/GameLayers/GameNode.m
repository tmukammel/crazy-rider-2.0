//
//  GameNode.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 5/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GameNode.h"
#import "TextureManager.h"
#import "GameMenu.h"
#include "GameHud.h"
#import "RVRCoin.h"
#import "Obstacles.h"
#import "DBPurchase.h"
#import "RVRAudioManager.h"

#pragma MARK - C Methods
float getPositionalRotaionAngle(CGPoint position){
    float angle=0.0f;
    float YDiff=MAXPOINT-position.y;
    CGSize winSize=[[CCDirector sharedDirector] viewSize];
    float XDiff=winSize.width/2-position.x;
    float grad;
    
    if (XDiff!=0) {
        grad=YDiff/XDiff;
        angle=atanf(grad);
    }
    else
        angle=0;
    
    if (angle>0)
        angle=90-(180/PI)*angle;
    else if(angle<0)
        angle=-(90+(180/PI)*angle);
    else //if(angle==0)
        angle=(180/PI)*angle;
    
    return angle;
}

float getDampedHarmonicXShift(CGPoint position){
    return expf(-position.y)*160.0f*cosf(position.y);
}

#pragma MARK - Private Methods Declaration
@interface GameNode (Private)

#pragma MARK - GameNode Private Methods
-(void)createBackgroundRoad;
-(void)generateSideBarStripes;
-(void)createAndAddBike;
-(void)generateRoadStripes;
-(void)generateTrees;
-(void)generateVehicleObstacles;
-(void)generateCoins;
-(void)generatePowerUpObjects;
-(void)updatePositionAndScale:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both;
-(void)updatePositionAndScaleForV:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both;
-(void)updatePositionAndScaleForBP:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both;
-(void)updatePositionAndScaleForTree:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both;
-(void)updatePositionAndScaleForPUp:(PowerUp*)pUp scaleX:(BOOL)scaleX saleBoth:(BOOL)both;
-(float)getXTransition:(float)yPos currentPos:(CGPoint)crntPos;
-(void)bringTrees;
-(void)bringVehicleObstacles;
-(void)bringBikerPoints;
-(void)setDoubleValueTexturesForBikerPoints;
-(void)resetTextureForBikerPoints;
-(void)bringPowerUpWithKey:(NSString*)key;
-(BOOL)isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp;
-(BOOL)checkCollission;
-(void)bikerPointsCollection;
-(void)invalidateSuperSpeedyStarterBtns;
-(void)disableAllPowerUps;
-(void)hideNode:(CCNode*)node;

-(void)loadExplosionBatchNode;
-(BOOL)shootVehicle:(NSInteger)movingVIndx;
-(void)crushBike;

#pragma MARK - Button Control Methods
-(void)createMenuButtons;
-(void)createAndShowPauseModeLayer;
-(BOOL)menuButtonClicked:(id)sender btn:(CCSprite*)btn;
-(void)bringGameOverMenu:(id)sender;
@end

#pragma MARK - GameNode Implementation
// GameNode implementation
@implementation GameNode

@synthesize delegate,bikeSprite,bSpeed,collectedBikerPoints,hasMagnet,isBikeAccelerating,isInvincible,hasAmmo,speedInMilesPerH,distanceInMiles,hasDoubleValuedCoins,hasCoinMultiplier,gameOverCount;

enum{
    nothing,
    buttonhome,
    buttonpause,
    buttonplay,
    buttonreplay,
    speedyStarter,
    speedyStarter2x,
};

enum{
    collectable,
    automatic,
};

enum{
    resume=1,
    revive=2,
    playagain=3,
    store=4,
    mainmenu=5,
};

+(CCScene *) scene
{
//	AppController *appDelegate=[[UIApplication sharedApplication] delegate];
    
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    GameHud *gameHud=[GameHud node];
    
	// 'layer' is an autorelease object.
	GameNode *layer = [GameNode node];
    
//    layer.scale=0.50f;
    
	// add layer as a child to scene
	[scene addChild: layer];
    
    [scene addChild:gameHud];
    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if((self=[super init])) {
        self.userInteractionEnabled=YES;
        //self.isAccelerometerEnabled=YES;
        appDelegate=(AppController*)[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] viewSize];
        
        appDelegate.gNode=self;
        appDelegate.gamePlayRunning=YES;
        
        //[CCTexture setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        currentSpeed=INITIALSPEED;
        menuButtons=[[NSMutableArray alloc] init];
        movingVehicles=[[NSMutableArray alloc] init];
        movingBikerPoints=[[NSMutableArray alloc] init];
        movingTrees=[[NSMutableArray alloc] init];
        self.collectedBikerPoints=[[NSMutableArray alloc] init];
        
        distMsg.distanceForCollectable=HUGE_VALF;
        distMsg.distanceForAutomatic=HUGE_VALF;
        distMsg.distanceForSuperSpeedyStarter=HUGE_VALF;
        shouldAlertForCollectableDisCovrd=YES;
        shootCount=0;
        
        _rt = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height];
        [self addChild:_rt];
        _rt.visible = NO;
        
        [[PauseOrGameOverMenu menu] setDelegate:self];
        
        [self createBackgroundRoad];
        [self createMenuButtons];
        [self generateSideBarStripes];
        [self generateRoadStripes];
        [self generateTrees];
        [self generateVehicleObstacles];
        
        [self createAndAddBike];
        magneticInductionRect=CGRectMake(0.0f, self.bikeSprite.position.y, winSize.width, self.bikeSprite.contentSize.height);
        
        [self generateCoins];
        
        [self generatePowerUpObjects];
        
        [self loadExplosionBatchNode];
        explosionBatchNode.visible=YES;
        
        [self schedule:@selector(update:) interval:0];
        [[RVRAudioManager sharedManager] playBikeEngineSound:YES];
        
        [self performSelector:@selector(bringVehicleObstacles) withObject:nil afterDelay:1.0f];
        [self performSelector:@selector(bringBikerPoints) withObject:nil afterDelay:1.0f];
        [self performSelector:@selector(bringTrees) withObject:nil afterDelay:1.0f];
	}
	return self;
}

-(BOOL) isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp{
    BOOL isCollision = NO; 
    CGRect intersection = CGRectIntersection([spr1 boundingBoxInPixels], [spr2 boundingBoxInPixels]);
    
    // Look for simple bounding box collision
    if (!CGRectIsEmpty(intersection))
    {
        // If we're not checking for pixel perfect collisions, return true
        if (!pp) {return YES;}
        
        // Get intersection info
        unsigned int x = intersection.origin.x;
        unsigned int y = intersection.origin.y;
        unsigned int w = intersection.size.width;
        unsigned int h = intersection.size.height;
        unsigned int numPixels = w * h;
        
        //NSLog(@"intersection = (%u,%u,%u,%u), area = %u",x,y,w,h,numPixels);
        
        // Draw into the RenderTexture
        [_rt beginWithClear:0 g:0 b:0 a:0];
        
        // Render both sprites: first one in RED and second one in GREEN
        glColorMask(1, 0, 0, 1);
        [spr1 visit];
        glColorMask(0, 1, 0, 1);
        [spr2 visit];
        glColorMask(1, 1, 1, 1);
        
        // Get color values of intersection area
        ccColor4B *buffer = malloc( sizeof(ccColor4B) * numPixels );
        glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
        [_rt end];
        
        // Read buffer
        unsigned int step = 1;
        for(unsigned int i=0; i<numPixels; i+=step)
        {
            ccColor4B color = buffer[i];
            
            if (color.r > 0 && color.g > 0)
            {
                isCollision = YES;
                break;
            }
        }
        
        // Free buffer memory
        free(buffer);
    }
    
    return isCollision;
}

-(CCSprite*)createSampleTexture:(CGSize)size{
    
    CCRenderTexture *roadTexture=[CCRenderTexture renderTextureWithWidth:size.width height:size.height];
    [roadTexture beginWithClear:255 g:255 b:255 a:255];
    /*
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    */
    [roadTexture end];
    return [CCSprite spriteWithTexture:roadTexture.sprite.texture];
}

-(CCSprite*)createSampleTexture1:(CGSize)size{
    
    CCRenderTexture *roadTexture=[CCRenderTexture renderTextureWithWidth:size.width height:size.height];
    [roadTexture beginWithClear:0 g:0 b:255 a:255];
    
    glDisable(GL_TEXTURE_2D);
//    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    [roadTexture end];
    return [CCSprite spriteWithTexture:roadTexture.sprite.texture];
}

-(void)createBackgroundRoad{
    CCSprite *road=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"roadTexture"]];
    road.anchorPoint=ccp(0.0f, 0.0f);
    [self addChild:road];
    
    sidebarleft=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"sidebarleft"]];
    [[sidebarleft texture] setAntialiased:NO];
    sidebarleft.anchorPoint=ccp(0.0f, 1.0f);
    sidebarleft.position=ccp(0.0f, winSize.height);
    [self addChild:sidebarleft];
    
    sidebarright=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"sidebarright"]];
    [[sidebarright texture] setAntialiased:NO];
    sidebarright.anchorPoint=ccp(1.0f, 1.0f);
    sidebarright.position=ccp(winSize.width, winSize.height);
    [self addChild:sidebarright];
}

-(void)createAndAddBike{
    bikeSprite=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"bikeTexture"]];
    [[bikeSprite texture] setAntialiased:NO];
    bikeSprite.anchorPoint=ccp(0.5f, 0.0f);
    bikeSprite.position=ccp(winSize.width/2, 64.0f);
    bikeSprite.scale=1.0f;
    [self addChild:bikeSprite z:3];
    
    /*
     CGRect bound=[self.bikeSprite boundingBox];
     
     CCSprite *sprt=[self createSampleTexture1:CGSizeMake(bound.size.width, bound.size.height)];
     sprt.anchorPoint=ccp(0.0f, 0.0f);
     sprt.position=ccp(bound.origin.x, bound.origin.y);
     [self addChild:sprt];
     
     CGSize BCBoxSize=CGSizeMake(self.bikeSprite.contentSizeInPixels.width, self.bikeSprite.contentSizeInPixels.height/4);
     BCBoundingBox=CGRectApplyAffineTransform(CGRectMake(0.0f, 0.0f, BCBoxSize.width, BCBoxSize.height), [self.bikeSprite nodeToParentTransform]);
     
     sprt=[self createSampleTexture:CGSizeMake(BCBoundingBox.size.width, BCBoundingBox.size.height)];
     sprt.anchorPoint=ccp(0.0f, 0.0f);
     sprt.position=ccp(BCBoundingBox.origin.x, BCBoundingBox.origin.y);
     [self addChild:sprt];*/
    /*
     CollissionRef=[self createSampleTexture:CGSizeMake(20, 32)];
     CollissionRef.anchorPoint=ccp(0.5f, 0.0f);
     CollissionRef.position=bikeSprite.position;//ccp(bikeSprite.contentSize.width/2, 0.0f);
     [self addChild:CollissionRef z:100];*/
}

-(void)generateSideBarStripes{
    sideBarStripes=[[NSMutableArray alloc] init];
    CGPoint previousPos;
    float XShift;
    
    for (int i=0; i<NOOFSIDEBARSTRIPES; i++) {
        CCSprite *roadStripe;
        if (i<(NOOFSIDEBARSTRIPES/2)) {
            roadStripe=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"side-stripe-left"]];
            roadStripe.anchorPoint=ccp(0.0f, 1.0f);
        }
        else{
            roadStripe=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"side-stripe-right"]];
            roadStripe.anchorPoint=ccp(1.0f, 1.0f);
        }
        
        //position formulae, !should be re-engineered
        if (i%NOOFSIDEBARSTRIPESPERCOL==0) {
            XShift=winSize.width/2-(155.0f+roadStripe.contentSize.width)+((310.0f+(roadStripe.contentSize.width*2))*(i/NOOFSIDEBARSTRIPESPERCOL));
            roadStripe.position=ccp(XShift, roadStripe.contentSize.height);
        }
        else{
            XShift=[self getXTransition:roadStripe.contentSize.height+((i%NOOFSIDEBARSTRIPESPERCOL)*BARSTRIPESAPCONST) currentPos:previousPos];
            roadStripe.position=ccp(XShift, roadStripe.contentSize.height+((i%NOOFSIDEBARSTRIPESPERCOL)*BARSTRIPESAPCONST));
        }
        previousPos=roadStripe.position;
        
        //scaling formulae
        roadStripe.scale=winSize.height/(winSize.height+roadStripe.position.y);
        
//        NSLog(@"scale-->%f",roadStripe.scale);
        
        [self addChild:roadStripe z:1];
        
        [sideBarStripes addObject:roadStripe];
    }
}

-(void)generateTrees{
    trees=[[NSMutableArray alloc] init];
    CGPoint previousPos;
    float XShift;
    
    for (int i=0; i<NOOFTREES; i++) {
        CCSprite *roadStripe=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"treeTexture"]];
        roadStripe.anchorPoint=ccp(0.5f, 0.5f);
        
        //position formulae, !should be re-engineered
        if (i%NOOFTREESPERCOL==0) {
            XShift=winSize.width/2-200+(400*(i/NOOFTREESPERCOL));
            XShift=[self getXTransition:-110.0f currentPos:ccp(XShift, 0.0f)];
            roadStripe.position=ccp(XShift, -110.0f);
            previousPos=roadStripe.position;
        }
        else
            roadStripe.position=previousPos;
        
        //        roadStripe.rotation=getPositionalRotaionAngle(roadStripe.position);
        
        //scaling formulae
        roadStripe.scale=winSize.height/(winSize.height+roadStripe.position.y);
        
        [self addChild:roadStripe z:5];
        
        [trees addObject:roadStripe];
    }
}

-(void)bringTrees{
    isTreesMoving=NO;
    [movingTrees removeAllObjects];
    int noOfVToBring=1+(arc4random()%2);
    int selectedVIndx;
    float XShift;
    
    float distance=650.0f;
    
    for (int i=0; i<noOfVToBring; i++) {
        
        selectedVIndx=arc4random()%4;
        
        //NSLog(@"selected biker point indx--->%d",selectedVIndx);
        if (![movingTrees containsObject:[trees objectAtIndex:selectedVIndx]]) {
            CCSprite *tree=[trees objectAtIndex:selectedVIndx];
            
            distance=distance+(i*tree.contentSize.height);
            XShift=[self getXTransition:distance currentPos:tree.position];
            tree.position=ccp(XShift, distance);
            
            [movingTrees addObject:[trees objectAtIndex:selectedVIndx]];
        }
        
    }
    isTreesMoving=YES;
}

-(void)generateRoadStripes{
    roadStripes=[[NSMutableArray alloc] init];
    CGPoint previousPos;
    float XShift;
    
    for (int i=0; i<NOOFROADSTRIPES; i++) {
        CCSprite *roadStripe=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"stripe1Texture"]];
        roadStripe.anchorPoint=ccp(0.5f, 1.0f);
        
        //position formulae, !should be re-engineered
        if (i%NOOFROADSTRIPESPERCOL==0) {
            XShift=winSize.width/2-40+(80*(i/NOOFROADSTRIPESPERCOL));
        }
        else
            XShift=[self getXTransition:roadStripe.contentSize.height+((i%NOOFROADSTRIPESPERCOL)*ROADSTRIPESAPCONST) currentPos:previousPos];
        roadStripe.position=ccp(XShift, roadStripe.contentSize.height+((i%NOOFROADSTRIPESPERCOL)*ROADSTRIPESAPCONST));//roadStripe.contentSize.height+(i*70)
        previousPos=roadStripe.position;
        
        roadStripe.rotation=getPositionalRotaionAngle(roadStripe.position);
        
        //scaling formulae
        roadStripe.scale=winSize.height/((roadStripe.contentSize.height*2)+(roadStripe.position.y*3));
        //--------------------------------------------------------------ˆ-change ths to change max scale, currently 1.0
        //----------------------------------------------------------------------------------------ˆ-change ths to change min scale, currently 0.2
        
        [self addChild:roadStripe z:1];
        
        [roadStripes addObject:roadStripe];
    }
}

-(void)generateVehicleObstacles{
    vehicleObstacles=[[NSMutableArray alloc] init];
    CGPoint previousPos;
    float XShift;
    //Required OnWhichLane???!!!
    for (int i=0; i<NOOFVEHICLES; i++) {
        Obstacles *roadStripe=[Obstacles generateObstacleWithAliasTextureParam];
        
        if (i%NOOFVEHICLESPERCOL==0) {
            XShift=(winSize.width/2.0f)-120.0f+(120.0f*(i/NOOFVEHICLESPERCOL));
            XShift=[self getXTransition:-20.0f currentPos:ccp(XShift, 0.0f)];
            roadStripe.position=roadStripe.initialPosition=ccp(XShift, -20.0f);
            previousPos=roadStripe.position;
        }
        else
            roadStripe.position=roadStripe.initialPosition=previousPos;
        //NSLog(@"ini pos x--->%f",roadStripe.initialPosition.x);
        
        [self addChild:roadStripe z:2];
        
        [vehicleObstacles addObject:roadStripe];
    }
}

-(void)bringVehicleObstacles{
    isVehicleMoving=NO;
    [movingVehicles removeAllObjects];
    int noOfVToBring=(arc4random()%3)+1;
    int selectedRoadLanes[3];
    int selectedVIndx[3];
    float XShift;
    
    float distance=550.0f;
    
    for (int i=0; i<noOfVToBring; i++) {
        selectedRoadLanes[i]=arc4random()%3;
        
        selectedVIndx[i]=selectedRoadLanes[i]*NOOFVEHICLESPERCOL;
        
        if (selectedVIndx[1]==selectedVIndx[0]) {
            selectedVIndx[1]=selectedVIndx[0]+1;
        }
        if (selectedVIndx[2]==selectedVIndx[0]) {
            selectedVIndx[2]=selectedVIndx[0]+1;
        }
        
        //temp works
//        float distance=550.0f+(((arc4random()%3)+1)*20*selectedVIndx[i]);
        if (![movingVehicles containsObject:[vehicleObstacles objectAtIndex:selectedVIndx[i]]]) {
            Obstacles *vehicle=[vehicleObstacles objectAtIndex:selectedVIndx[i]];
            [vehicle resetProperties];
            
            distance=distance+(i*vehicle.contentSize.height);
            
            vehicle.visible=YES;
            XShift=[self getXTransition:distance currentPos:vehicle.position];
            
            vehicle.scale=winSize.height/(winSize.height+distance);
            
            vehicle.position=ccp(XShift, distance);
            [movingVehicles addObject:[vehicleObstacles objectAtIndex:selectedVIndx[i]]];
        }
    }
    
    for (int i=0; i<([movingVehicles count]-1); i++) {
        if (i<2) {
            Obstacles *vehicle1=[movingVehicles objectAtIndex:i];
            Obstacles *vehicle2=[movingVehicles objectAtIndex:i+1];
            if (vehicle1.initialPosition.x==vehicle2.initialPosition.x &&
                vehicle2.vehicleSpeed>vehicle1.vehicleSpeed) {
                vehicle2.vehicleSpeed=vehicle1.vehicleSpeed;
            }
        }
    }
    if ([movingVehicles count]>2) {
        Obstacles *vehicle1=[movingVehicles objectAtIndex:0];
        Obstacles *vehicle2=[movingVehicles objectAtIndex:2];
        if (vehicle1.initialPosition.x==vehicle2.initialPosition.x &&
            vehicle2.vehicleSpeed>vehicle1.vehicleSpeed) {
            vehicle2.vehicleSpeed=vehicle1.vehicleSpeed;
        }
    }
    /*
    NSLog(@"------");
    for (int i=0;i<[movingVehicles count];i++) {
        Obstacles *obj=[movingVehicles objectAtIndex:i];
        NSLog(@"ini posX->%f indx->%d speed->%f",obj.initialPosition.x,i,obj.vehicleSpeed);
    }
    */
    isVehicleMoving=YES;
}

-(void)generateCoins{
    bikerPoints=[[NSMutableArray alloc] init];
    CGPoint previousPos;
    float XShift;
    
    for (int i=0; i<NOOFCOINS; i++) {
        RVRCoin *roadStripe=[RVRCoin generateCoinWithAliasTexParameters];
        
        if (i%NOOFCOINSPERCOL==0) {
            XShift=winSize.width/2-120+(120*(i/NOOFCOINSPERCOL));
            XShift=[self getXTransition:-20.0f currentPos:ccp(XShift, 0.0f)];
            roadStripe.position=ccp(XShift, -20.0f);
            
            previousPos=roadStripe.position;
        }
        else
            roadStripe.position=previousPos;
        
        [roadStripe setMyOriginalPosition];
        
//        NSLog(@"coin no ->%d pos--->%f,%f",i, roadStripe.position.x, roadStripe.position.y);
        
        [self addChild:roadStripe];
        
        [bikerPoints addObject:roadStripe];
    }
}

-(void)bringBikerPoints{
    isBikerPointsMoving=NO;
    [movingBikerPoints removeAllObjects];
    int noOfVToBring=NOOFCOINSPERCOL;
    int selectedRoadLanes=arc4random()%3;
    int selectedVIndx;
    float XShift;
    
    float distance=700+(((arc4random()%3)+1)*100);
    float distStore=distance;
    
    for (int i=0; i<noOfVToBring; i++) {
        
        selectedVIndx=(selectedRoadLanes*NOOFCOINSPERCOL)+i;
        
        //NSLog(@"selected biker point indx--->%d",selectedVIndx);
        
        RVRCoin *coin=[bikerPoints objectAtIndex:selectedVIndx];
        coin.visible=YES;
        
        XShift=[self getXTransition:distance currentPos:coin.position];
        coin.position=ccp(XShift, distance);
        
        [coin setPaused:NO];
        
        [movingBikerPoints addObject:coin];
        
        distance+=(COINSSAPCONST-(COINSSAPCONST/100.0f*i));
    }
    
    int another=arc4random()%2;
    if (another==1) {
        int lane=arc4random()%3;
        if (lane!=selectedRoadLanes) {
            for (int i=0; i<noOfVToBring; i++) {
                
                selectedVIndx=(lane*NOOFCOINSPERCOL)+i;
                
                //NSLog(@"selected biker point indx--->%d",selectedVIndx);
                
                RVRCoin *coin=[bikerPoints objectAtIndex:selectedVIndx];
                coin.visible=YES;
                
                XShift=[self getXTransition:distStore currentPos:coin.position];
                coin.position=ccp(XShift, distStore);
                
                [coin setPaused:NO];
                
                [movingBikerPoints addObject:coin];
                
                distStore+=(COINSSAPCONST-(COINSSAPCONST/100.0f*i));
            }
        }
    }
    
    isBikerPointsMoving=YES;
}

-(void)setDoubleValueTexturesForBikerPoints{
    for (int i=0; i<[bikerPoints count]; i++) {
        if (i%2==0) {
            RVRCoin *coin=[bikerPoints objectAtIndex:i];
            [coin setDoubleValueTexture];
        }
    }
    self.hasDoubleValuedCoins=YES;
    [self bringBikerPoints];
}

-(void)resetTextureForBikerPoints{
    for (int i=0; i<[bikerPoints count]; i++) {
        if (i%2==0) {
            RVRCoin *coin=[bikerPoints objectAtIndex:i];
            [coin resetToOriginalTexture];
        }
    }
    self.hasDoubleValuedCoins=NO;
    [self bringBikerPoints];
    [[RVRPowerUpsAndPurchasesController powerUpsAndPurchasesController] requestForAutomaticPowerUp];
}

-(void)generatePowerUpObjects{
    if ([RVRPowerUpsAndPurchasesController powerUpsAndPurchasesController]!=nil) {
        self.delegate=[RVRPowerUpsAndPurchasesController powerUpsAndPurchasesController];
        [RVRPowerUpsAndPurchasesController powerUpsAndPurchasesController].delegate=self;
        powerUpSpriteObjs=[[NSMutableDictionary alloc] init];
        
        NSMutableDictionary *powerUps=[RVRPowerUpsAndPurchasesController powerUpsAndPurchasesController].collectablePowerUps;
        
        float XShift=winSize.width/2;
        XShift=[self getXTransition:-20.0f currentPos:ccp(XShift, 0.0f)];
        
        for (DBUpgrades *pUpData in [powerUps allValues]) {
            //NSLog(@"name--->%@",pUpData.upgradeName);
            
            PowerUp *powerUp=[PowerUp generatePowerUpWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:[NSString stringWithFormat:@"pu-%@",pUpData.upgradeIcon]]];
            powerUp.stringTag=pUpData.upgradeName;
            powerUp.position=ccp(XShift, -20.0f);
            
            [self addChild:powerUp];
            
            [powerUpSpriteObjs setObject:powerUp forKey:pUpData.upgradeName];
        }
    }
}

-(void)bringPowerUpWithKey:(NSString *)key{
    PowerUp *pUp=[powerUpSpriteObjs objectForKey:key];
    if (pUp!=nil) {
        float XShift=[self getXTransition:winSize.height-pUp.position.y+100.0f currentPos:pUp.position];
        pUp.position=ccp(XShift, winSize.height-pUp.position.y+100.0f);
        pUp.visible=YES;
        movingPUp=pUp;
        isPowerUpMoving=YES;
    }
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
    
    if (clickedButtonTag==nothing) {
        for (CCSprite *btn in menuButtons) {
            if (CGRectContainsPoint([btn boundingBox], location)) {
                clickedButtonTag=btn.tag;
                return;
            }
        }
        for (CCSprite *btn in superSpeedyBtns) {
            if (CGRectContainsPoint([btn boundingBox], location)) {
                clickedButtonTag=btn.tag;
                return;
            }
        }
    }
    
//    isAccelerating=YES;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
    
    if (clickedButtonTag!=nothing) {
        for (CCSprite *btn in menuButtons) {
            if (CGRectContainsPoint([btn boundingBox], location) && btn.tag==clickedButtonTag) {
                [self menuButtonClicked:self btn:btn];
                return;
            }
        }
        
        for (CCSprite *btn in superSpeedyBtns) {
            if (CGRectContainsPoint([btn boundingBox], location) && btn.tag==clickedButtonTag) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(invalidateSuperSpeedyStarterBtns) object:nil];
                for (CCSprite *btn in superSpeedyBtns) {
                    btn.visible=NO;
                    btn.tag=nothing;
                }
                if (clickedButtonTag==speedyStarter)
                    [self.delegate speedyStarterUsedWithTag:@"Super Speedy Starter"];
                else if(clickedButtonTag==speedyStarter2x)
                    [self.delegate speedyStarterUsedWithTag:@"Super Speedy Starter 2x"];
                return;
            }
        }
        clickedButtonTag=nothing;
    }
    
//    isAccelerating=NO;
}

-(void)hideNode:(CCNode *)node{
    node.visible=NO;
    node.tag=nothing;
}

-(void)invalidateSuperSpeedyStarterBtns{
    for (CCSprite *btn in superSpeedyBtns) {
        CCActionFadeOut *fadeOut=[CCActionFadeOut actionWithDuration:2.0f];
        CCActionCallFuncO *hide=[CCActionCallFuncO actionWithTarget:self selector:@selector(hideNode:) object:btn];
        CCActionSequence *sequence=[CCActionSequence actions:fadeOut,hide, nil];
        [btn runAction:sequence];
    }
}

-(void)disableAllPowerUps{
    for (PowerUp *pUp in [powerUpSpriteObjs allValues]) {
        pUp.inValidateNextDisableCall=NO;
    }
    self.hasMagnet=NO;
    self.hasCoinMultiplier=NO;
    self.bikeSprite.opacity=255.0f;
    self.isInvincible=NO;
    self.hasAmmo=NO;
    isAccelerating=NO;
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    static float prevX=0, prevY=0;
    
    #define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
    float angle=(accelX*45)+getPositionalRotaionAngle(self.bikeSprite.position);
    CCActionRotateTo *rotateTo=[CCActionRotateTo actionWithDuration:0.1 angle:angle];//accelX*maxInclination
    [self.bikeSprite runAction:rotateTo];
    
    
    float absRotation;
    if (self.bikeSprite.rotation<0)
        absRotation=-1*self.bikeSprite.rotation;
    else
        absRotation=self.bikeSprite.rotation;
    
    //NSLog(@"absrotation--->%f",absRotation);
    
    absRotation*=7;
    
    //NSLog(@"absrotation after--->%f",absRotation);
    
    CGPoint pos=self.bikeSprite.position;
    //float actionDuration=0.10f*(MAXSPEED/currentSpeed);
    
    if (pos.x+(accelX*XSHIFTCONST)>30.0f && pos.x+(accelX*XSHIFTCONST)<290.0f) {
        
//        CCMoveBy *moveBy=[CCMoveBy actionWithDuration:actionDuration position:ccp(accelX*absRotation, 0.0f)];
        CCActionMoveBy *moveBy=[CCActionMoveBy actionWithDuration:0.14f position:ccp(accelX*XSHIFTCONST, 0.0f)];
        
        //NSLog(@"x pos shift--->%f",accelX*150);
        
        [self.bikeSprite runAction:moveBy];
    }
    else if(pos.x>30.0f && accelX<0.0f){
//        CCMoveTo *moveBy=[CCMoveTo actionWithDuration:actionDuration position:ccp(20.1f, pos.y)];
        CCActionMoveTo *moveBy=[CCActionMoveTo actionWithDuration:0.14f position:ccp(30.1f, pos.y)];
        
        [self.bikeSprite runAction:moveBy];
    }
    else if(pos.x<290.0f && accelX>0.0f){
//        CCMoveTo *moveBy=[CCMoveTo actionWithDuration:actionDuration position:ccp(299.9f, pos.y)];
        CCActionMoveTo *moveBy=[CCActionMoveTo actionWithDuration:0.14f position:ccp(289.9f, pos.y)];
        
        [self.bikeSprite runAction:moveBy];
    }
//    NSLog(@"acceleration--->%f,%f",accelX,accelX);
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

-(void)updatePositionAndScale:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both{
    CGPoint prevPos;
    
    NSString *arrayType;
    if ([sideBarStripes containsObject:[array objectAtIndex:0]])
        arrayType=@"sideBar";
    else if([roadStripes containsObject:[array objectAtIndex:0]])
        arrayType=@"road";
    else if([trees containsObject:[array objectAtIndex:0]])
        arrayType=@"tree";
    
    for (CCSprite *stripe in array) {
        prevPos=stripe.position;
        
        float XPos=[self getXTransition:stripe.position.y-currentSpeed currentPos:stripe.position];
        
        stripe.position=ccp(XPos, stripe.position.y-currentSpeed);
        
        if (stripe.position.y<0 || (stripe.position.x+stripe.contentSize.width<0 || stripe.position.x-stripe.contentSize.width>winSize.width)) {
            int indx=[array indexOfObject:stripe];
            int targetedStripeIndx;
            
            if (arrayType==@"sideBar") {
                if (indx%NOOFSIDEBARSTRIPESPERCOL==0) {
                    targetedStripeIndx=indx+(NOOFSIDEBARSTRIPESPERCOL-1);
                }
                else
                    targetedStripeIndx=indx-1;
            }
            else if(arrayType==@"road"){
                if (indx%NOOFROADSTRIPESPERCOL==0) {
                    targetedStripeIndx=indx+(NOOFROADSTRIPESPERCOL-1);
                }
                else
                    targetedStripeIndx=indx-1;
            }
            else if(arrayType==@"tree"){
                if (indx%NOOFTREESPERCOL==0) {
                    targetedStripeIndx=indx+(NOOFTREESPERCOL-1);
                }
                else
                    targetedStripeIndx=indx-1;
            }
            
            CCSprite *targetStripe=[array objectAtIndex:targetedStripeIndx];
            if(arrayType==@"sideBar"){
                XPos=[self getXTransition:targetStripe.position.y+BARSTRIPESAPCONST currentPos:prevPos];
                stripe.position=ccp(XPos, targetStripe.position.y+BARSTRIPESAPCONST);
            }
            else if(arrayType==@"road"){
                XPos=[self getXTransition:targetStripe.position.y+ROADSTRIPESAPCONST currentPos:prevPos];
                stripe.position=ccp(XPos, targetStripe.position.y+ROADSTRIPESAPCONST);
            }
            else if(arrayType==@"tree"){
                XPos=[self getXTransition:targetStripe.position.y+TREESEPCONST currentPos:prevPos];
                stripe.position=ccp(XPos, targetStripe.position.y+TREESEPCONST);
            }
        }
        //NSLog(@"stripe pos--->%f,%f",stripe.position.x,stripe.position.y);
        if (both){
            if (arrayType==@"sideBar" || arrayType==@"tree") {
                stripe.scale=winSize.height/(winSize.height+stripe.position.y);
            }
            else if(arrayType==@"road")
                //stripe.scale=winSize.height/((winSize.height*2)+(stripe.position.y*10));
                stripe.scale=winSize.height/((stripe.contentSize.height*2)+(stripe.position.y*3));
        }
        else if(scaleX)
            stripe.scaleX=winSize.height/((stripe.contentSize.height*2)+(stripe.position.y*3));
        else
            stripe.scaleY=winSize.height/((stripe.contentSize.height*2)+(stripe.position.y*3));
    }
}

-(void)updatePositionAndScaleForV:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both{
    CGPoint prevPos;
    noOfVs=[movingVehicles count];
    for (vCount=0;vCount<noOfVs;vCount++) {
        int i=vCount;
        Obstacles *stripe=[movingVehicles objectAtIndex:i];
        prevPos=stripe.position;
        float XPos;
        if (stripe.isToChangeLane==YES && stripe.position.y<=stripe.laneChangeDest.y &&
            (
             (stripe.laneChangeDir>0 && stripe.laneChangeDest.x-stripe.position.x>0) ||
             (stripe.laneChangeDir<0 && stripe.position.x-stripe.laneChangeDest.x>0)
            )
           ) {
            XPos=stripe.position.x+stripe.laneChangeSpeed;
        }
        else
            XPos=[self getXTransition:stripe.position.y-stripe.vehicleSpeed currentPos:stripe.position];
        
        stripe.position=ccp(XPos, stripe.position.y-stripe.vehicleSpeed);
        
        if (both)
            stripe.scale=winSize.height/(winSize.height+stripe.position.y);
        
        if (stripe.position.y<=-20) {
            stripe.position=stripe.initialPosition;
            
            [movingVehicles removeObject:stripe];
            noOfVs--;
            vCount--;
        }
        else if (self.hasAmmo==YES && stripe.position.y<=winSize.height-120.0f && stripe.position.y>0 && shootCount<NOOFEXPLOSIONSPRITES && stripe.isShooted!=YES) {
            NSLog(@"going to shoot--->%d",shootCount);
            stripe.isShooted=YES;
            [self shootVehicle:vCount];
        }
    }
    if ([movingVehicles count]==0) {
        [self bringVehicleObstacles];
    }
}

-(void)updatePositionAndScaleForBP:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both{
    CGPoint prevPos;
    int noOfBPs=[movingBikerPoints count];
    for (int i=0;i<noOfBPs;i++) {
        RVRCoin *stripe=[movingBikerPoints objectAtIndex:i];
        prevPos=stripe.position;
        
        float XPos=[self getXTransition:stripe.position.y-currentSpeed currentPos:stripe.position];
        
        stripe.position=ccp(XPos, stripe.position.y-currentSpeed);
        
        if (stripe.position.y<-20) {
            [stripe resetToMyOriginalPos];
            [stripe setPaused:YES];
            
            [movingBikerPoints removeObject:stripe];
            noOfBPs--;
            i--;
        }
        
        if (both){
            //stripe.scale=winSize.height/((stripe.contentSize.height*4)+(stripe.position.y));
            //stripe.scale=winSize.height/((stripe.contentSize.height*2)+(stripe.position.y*3));
        }
    }
    if ([movingBikerPoints count]==0) {
        if (waitingForEnablingDoubleValue==YES) {
            waitingForEnablingDoubleValue=NO;
            [self setDoubleValueTexturesForBikerPoints];
        }
        else if(waitingForResettingBikerPoints==YES){
            waitingForResettingBikerPoints=NO;
            [self resetTextureForBikerPoints];
        }
        else
            [self bringBikerPoints];
    }
}

-(void)updatePositionAndScaleForTree:(NSMutableArray*)array scaleX:(BOOL)scaleX saleBoth:(BOOL)both{
    CGPoint prevPos;
    int noOfBPs=[movingTrees count];
    for (int i=0;i<noOfBPs;i++) {
        CCSprite *stripe=[movingTrees objectAtIndex:i];
        prevPos=stripe.position;
        
        float XPos=[self getXTransition:stripe.position.y-currentSpeed currentPos:stripe.position];
        
        stripe.position=ccp(XPos, stripe.position.y-currentSpeed);
        
        if (stripe.position.y<=-110) {
            [movingTrees removeObject:stripe];
            noOfBPs--;
            i--;
        }
        
        if (both){
            stripe.scale=winSize.height/(winSize.height+stripe.position.y);
        }
    }
    if ([movingTrees count]==0) {
        [self bringTrees];
    }
}

-(void)updatePositionAndScaleForPUp:(PowerUp*)pUp scaleX:(BOOL)scaleX saleBoth:(BOOL)both{
        
    float XPos=[self getXTransition:pUp.position.y-vCurrentSpeed currentPos:pUp.position];
    
    pUp.position=ccp(XPos, pUp.position.y-vCurrentSpeed);
    
    if (pUp.position.y<=-20) {
        isPowerUpMoving=NO;
        if (shouldAlertForCollectableDisCovrd==YES){
            [self.delegate newCollectablePowerUpAppearanceRequest];
        }
    }
    
    if (both){
        pUp.scale=winSize.height/(winSize.height+pUp.position.y);
    }
}

-(BOOL)checkCollission{
    BOOL collission=NO;
    
    if (self.isInvincible==NO) {
        for (Obstacles *vehicle in vehicleObstacles) {
            if ([self isCollisionBetweenSpriteA:self.bikeSprite spriteB:vehicle pixelPerfect:YES]) {
                vehicleCollidedWith=vehicle;
                collission=YES;
            }
        }
    }
    
    if (isPowerUpMoving && [self isCollisionBetweenSpriteA:self.bikeSprite spriteB:movingPUp pixelPerfect:YES]) {
        movingPUp.visible=NO;
        [self.delegate collectablePowerUpCollected:movingPUp.stringTag];
    }
    
    /*
    if (collission==NO) {
        if ([self isCollisionBetweenSpriteA:self.bikeSprite spriteB:sidebarleft pixelPerfect:YES] ||
            [self isCollisionBetweenSpriteA:self.bikeSprite spriteB:sidebarright pixelPerfect:YES]) {
            NSLog(@"colliding with side bar");
            collission=YES;
        }
    }
    */
    return collission;
}

-(void)bikerPointsCollection{
    int noOfMovingBP=[movingBikerPoints count];
    BOOL isCollected=NO;
    for (int i=0; i<noOfMovingBP; i++) {
        RVRCoin *bPoint=[movingBikerPoints objectAtIndex:i];
        BOOL isCollission=[self isCollisionBetweenSpriteA:self.bikeSprite spriteB:bPoint pixelPerfect:YES];
        if (isCollission) {
            [[RVRAudioManager sharedManager] playCoinCollectionSound];
            [self.collectedBikerPoints addObject:bPoint];
            
            [bPoint performCoinCollectionAndAnimation];
            
            [movingBikerPoints removeObject:bPoint];
            noOfMovingBP--;
            i--;
            isCollected=YES;
        }
        else if (self.hasMagnet==YES && CGRectIntersectsRect([bPoint boundingBox], magneticInductionRect)) {
            [[RVRAudioManager sharedManager] playCoinCollectionSound];
            [self.collectedBikerPoints addObject:bPoint];
            
            [bPoint performMagnetInducedCollectionAnimation];
            
            [movingBikerPoints removeObject:bPoint];
            noOfMovingBP--;
            i--;
            isCollected=YES;
        }
        if (isCollected) {
            isCollected=NO;
            int coinToAdd=1;
            if (self.hasCoinMultiplier==YES) {
                coinToAdd=2;
            }
            if (self.hasDoubleValuedCoins) {
                coinToAdd=coinToAdd*2;
            }
            appDelegate.databaseManager.userData.uCoins+=coinToAdd;
            [appDelegate.gHud.coinsLabel setString:[NSString stringWithFormat:@"%d",appDelegate.databaseManager.userData.uCoins]];
        }
    }
    if ([movingBikerPoints count]==0) {
        if (waitingForEnablingDoubleValue==YES) {
            waitingForEnablingDoubleValue=NO;
            [self setDoubleValueTexturesForBikerPoints];
        }
        else if(waitingForResettingBikerPoints==YES){
            waitingForResettingBikerPoints=NO;
            [self resetTextureForBikerPoints];
        }
        else
            [self bringBikerPoints];
    }
}

-(void)pauseGameOnEnteringBackGround{
    if (willBringGameOverMenu==NO) {
        for (CCSprite *btn in menuButtons) {
            btn.visible=NO;
        }
        self.userInteractionEnabled=NO;
        [self.bikeSprite setPaused:YES];
        //self.isAccelerometerEnabled=NO;
        [self stopAllActions];
        [self setPaused:YES];
        for (RVRCoin *BPoint in movingBikerPoints) {
            [BPoint setPaused:YES];
        }
        for (RVRCoin *bPoint in self.collectedBikerPoints) {
            [bPoint.aliasCoin setPaused:YES];
        }
        for (CCSprite *child in [explosionBatchNode children]) {
            [child setPaused:YES];
        }
        [[RVRAudioManager sharedManager] playBikeEngineSound:NO];
        //[self createAndShowPauseModeLayer];
        [[PauseOrGameOverMenu menu] pauseMenu];
    }
}

- (void)update:(CCTime)dt {
    if (!isPUpPCAlertSent) {
        isPUpPCAlertSent=YES;
        [self.delegate gamePlayStarted];
    }
    if (isAccelerating && currentSpeed<MAXSPEED){
        if (currentSpeed+ACCELERATION<MAXSPEED){
            currentSpeed+=ACCELERATION;
            self.isBikeAccelerating=1;
        }
        else{
            currentSpeed=MAXSPEED;
            self.isBikeAccelerating=0;
        }
        //temp works
        vCurrentSpeed=(currentSpeed/10.0f)*3.5f;
    }
    else if(!isAccelerating && reducingFromMax){
        if (currentSpeed+RETARDATION>speedBeforeSSS) {
            currentSpeed+=RETARDATION;
            self.isBikeAccelerating=-1;
        }
        else{
            shouldAlertForCollectableDisCovrd=YES;
            [self.delegate newCollectablePowerUpAppearanceRequest];
            currentSpeed=speedBeforeSSS;
            reducingFromMax=NO;
            self.bikeSprite.opacity=255.0f;
            self.isInvincible=NO;
            self.isBikeAccelerating=0;
        }
        //temp works
        vCurrentSpeed=(currentSpeed/10.0f)*3.5f;
    }
    else if(!isAccelerating && currentSpeed<MAXSPEED){
        if (currentSpeed+NORMALACCELERATION<MAXSPEED) {
            currentSpeed+=NORMALACCELERATION;
            self.isBikeAccelerating=1;
        }
        else{
            currentSpeed=MAXSPEED;
            self.isBikeAccelerating=0;
        }
        //temp works
        vCurrentSpeed=(currentSpeed/10.0f)*3.5f;
    }
    
    self.bSpeed=currentSpeed;
    
    distanceInMiles+=(MILETOPIXELRATIO*currentSpeed);
    [appDelegate.gHud.distanceLabel setString:[NSString stringWithFormat:@"%0.2f  M",distanceInMiles]];
    
    if (distanceInMiles>=distMsg.distanceForCollectable && shouldAlertForCollectableDisCovrd==YES) {
        distMsg.distanceForCollectable=HUGE_VALF;
        [self.delegate distanceCoveredFor:collectable];
    }
    if (distanceInMiles>=distMsg.distanceForAutomatic && shouldAlertForCollectableDisCovrd==YES) {
        distMsg.distanceForAutomatic=HUGE_VALF;
        [self.delegate distanceCoveredFor:automatic];
    }
    if (distanceInMiles>=distMsg.distanceForSuperSpeedyStarter) {
        reducingFromMax=YES;
        distMsg.distanceForSuperSpeedyStarter=HUGE_VALF;
    }
    
    //speedInMilesPerH=(MILETOPIXELRATIO*(currentSpeed*60.0f*60.0f))*MINTOHRRATIO;
    //[appDelegate.gHud.speedLabel setString:[NSString stringWithFormat:@"%0.1f",speedInMilesPerH]];
    //appDelegate.gHud.meterArrow.rotation=METERARROWINIROTCONST+((speedInMilesPerH-70.0f)*(METERARROWROTATIONMAXADD/90.0f));
    //NSLog(@"rotation--->%f, speed--->%f",meterArrow.rotation,speedInMilesPerH);
    
    //NSLog(@"distance --->%f currentspeed--->%Lf speed--->%f",distanceInMiles,MILETOPIXELRATIO*(currentSpeed*120.0f*60.0f),speedInMilesPerH);
    
    [self updatePositionAndScale:roadStripes scaleX:NO saleBoth:YES];
    [self updatePositionAndScale:sideBarStripes scaleX:NO saleBoth:YES];
    
    if (isVehicleMoving==YES) {
        [self updatePositionAndScaleForV:movingVehicles scaleX:NO saleBoth:YES];
    }
    if (isBikerPointsMoving==YES) {
        [self updatePositionAndScaleForBP:movingBikerPoints scaleX:NO saleBoth:YES];
        [self bikerPointsCollection];
    }
    if (isPowerUpMoving==YES) {
        [self updatePositionAndScaleForPUp:movingPUp scaleX:NO saleBoth:YES];
    }
    if (isTreesMoving==YES) {
        [self updatePositionAndScaleForTree:movingTrees scaleX:NO saleBoth:YES];
    }
    
    if ([self checkCollission]==YES) {
        [self unschedule:@selector(update:)];
        //self.isAccelerometerEnabled=NO;
        willBringGameOverMenu=YES;
        self.gameOverCount+=1;
        [[RVRAudioManager sharedManager] playExplosionSound];
        [self crushBike];
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[roadStripes removeAllObjects];
    roadStripes=nil;
    [roadOverlays removeAllObjects];
    roadOverlays=nil;
    [vehicleObstacles removeAllObjects];
    vehicleObstacles=nil;
    [sideBarStripes removeAllObjects];
    sideBarStripes=nil;
    [movingVehicles removeAllObjects];
    movingVehicles=nil;
    [menuButtons removeAllObjects];
    menuButtons=nil;
    [bikerPoints removeAllObjects];
    bikerPoints=nil;
    [movingBikerPoints removeAllObjects];
    movingBikerPoints=nil;
    [self.collectedBikerPoints removeAllObjects];
    self.collectedBikerPoints=nil;
    [explosionBNChilds removeAllObjects];
    explosionBNChilds=nil;
    [trees removeAllObjects];
    trees=nil;
    [movingTrees removeAllObjects];
    movingTrees=nil;
    [powerUpSpriteObjs removeAllObjects];
    powerUpSpriteObjs=nil;
    [superSpeedyBtns removeAllObjects];
    superSpeedyBtns=nil;
    
    for (CCNode *child in self.children) {
        [child stopAllActions];
    }
    
    [self unscheduleAllSelectors];
    //[[CCTextureCache sharedTextureCache] removeTexture:[[_rt sprite] texture]];
    
	// don't forget to call "super dealloc"
//	[super dealloc];
}

#pragma MARK - RVRPowerUpsAndPurchasesDelegate Methods Implementation
-(void)alertWhenDistanceIs:(float)distance alertFor:(int)tag{
    if (tag==collectable) {
        distMsg.distanceForCollectable=distance;
    }
    else if (tag==automatic) {
        distMsg.distanceForAutomatic=distance;
    }
}

-(void)showPowerUpWithKey:(NSString *)key{
    [self bringPowerUpWithKey:key];
}

-(void)setInvincibilityMode:(BOOL)isYes{
    self.isInvincible=isYes;
    if (isYes==YES) {
        self.bikeSprite.opacity=127.0f;
    }
    else
        self.bikeSprite.opacity=255.0f;
}

-(void)enablePowerUpWithKey:(NSString *)key{
    if ([key isEqualToString:@"Magnet"]) {
        if (self.hasMagnet==YES) {
            NSLog(@"was enabled");
            PowerUp *pUp=[powerUpSpriteObjs objectForKey:key];
            pUp.inValidateNextDisableCall=YES;
        }
        else
            self.hasMagnet=YES;
    }
    else if([key isEqualToString:@"Multiplier"]){
        if (self.hasCoinMultiplier==YES) {
            PowerUp *pUp=[powerUpSpriteObjs objectForKey:key];
            pUp.inValidateNextDisableCall=YES;
        }
        else
            self.hasCoinMultiplier=YES;
    }
    else if([key isEqualToString:@"Invincibility"]){
        if (self.isInvincible==YES) {
            PowerUp *pUp=[powerUpSpriteObjs objectForKey:key];
            pUp.inValidateNextDisableCall=YES;
        }
        else{
            self.bikeSprite.opacity=127.0f;
            self.isInvincible=YES;
        }
    }
    else if([key isEqualToString:@"Shooter"]){
        if (self.hasAmmo==YES) {
            PowerUp *pUp=[powerUpSpriteObjs objectForKey:key];
            pUp.inValidateNextDisableCall=YES;
        }
        else
            self.hasAmmo=YES;
    }
    else if([key isEqualToString:@"NOS"]){
        if (isAccelerating==YES) {
            PowerUp *pUp=[powerUpSpriteObjs objectForKey:key];
            pUp.inValidateNextDisableCall=YES;
        }
        else
            isAccelerating=YES;
    }
    else if([key isEqualToString:@"doubleValue"]){
        waitingForEnablingDoubleValue=YES;
    }
    //Magnet,Multiplier,Invincibility,Shooter,Double Value Points,NOS
}

-(void)disablePowerUpWithKey:(NSString *)key{
    PowerUp *pUp=[powerUpSpriteObjs objectForKey:key];
    if (pUp.inValidateNextDisableCall==YES) {
        NSLog(@"previous call invalidated");
        pUp.inValidateNextDisableCall=NO;
    }
    else if ([key isEqualToString:@"Magnet"]) {
        self.hasMagnet=NO;
    }
    else if([key isEqualToString:@"Multiplier"]){
        self.hasCoinMultiplier=NO;
    }
    else if([key isEqualToString:@"Invincibility"]){
        self.bikeSprite.opacity=255.0f;
        self.isInvincible=NO;
    }
    else if([key isEqualToString:@"Shooter"]){
        //NSLog(@"disable shooter");
        self.hasAmmo=NO;
    }
    else if([key isEqualToString:@"NOS"]){
        isAccelerating=NO;
    }
    /*
    if (shouldAlertForCollectableDisCovrd==YES) {
        [self.delegate newCollectablePowerUpAppearanceRequest];
    }*/
}

-(void)addSuperSpeedyButtons:(NSArray *)values{
    superSpeedyBtns=[[NSMutableArray alloc] init];
    CCSprite *btn;
    CGSize prevSize;
    for (DBPurchase *purchase in values) {
        NSString *keyString=purchase.purchaseIcon;
        btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:[NSString stringWithFormat:@"%@",keyString]]];
        btn.anchorPoint=ccp(0.0f, 0.0f);
        btn.position=ccp(0.0f, 0.0f+prevSize.height);
        
        if ([keyString isEqualToString:@"superspeed"]) {
            btn.tag=speedyStarter;
        }
        else
            btn.tag=speedyStarter2x;
        
        [self addChild:btn z:100];
        [superSpeedyBtns addObject:btn];
        prevSize=btn.contentSize;
    }
    [self performSelector:@selector(invalidateSuperSpeedyStarterBtns) withObject:nil afterDelay:TWOLESSSPEEDYSTARTERBTNHIDETIME];
}

-(void)startWithSuperSpeed:(float)distToCover{
    [self disableAllPowerUps];
    if (self.hasDoubleValuedCoins==YES) {
        waitingForResettingBikerPoints=YES;
    }
    
    shouldAlertForCollectableDisCovrd=NO;
    speedBeforeSSS=INITIALSPEED;
    distMsg.distanceForSuperSpeedyStarter=self.distanceInMiles+distToCover;
    self.bikeSprite.opacity=127.0f;
    self.isInvincible=YES;
    currentSpeed=MAXSPEED;
}

#pragma MARK - Button Control Methods
-(void)createMenuButtons{
    if (pauseModeLayer!=nil) {
        [pauseModeLayer removeAllChildrenWithCleanup:YES];
        [pauseModeLayer removeFromParentAndCleanup:YES];
        pauseModeLayer=nil;
    }
    [menuButtons removeAllObjects];
    
    CCSprite *btn;
    
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"button-pause"]];
    
    btn.anchorPoint=ccp(1.0f, 0.0f);
    btn.position=ccp(winSize.width, 0.0f);
    [self addChild:btn z:100];
    btn.tag=buttonpause;
    [menuButtons addObject:btn];
}

-(void)addButtonsToPauseModeLayer{
    CCSprite *btn;
    CGSize layerSize=pauseModeLayer.contentSize;
    
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"button-play"]];
    btn.anchorPoint=ccp(0.5f, 0.0f);
    btn.position=ccp(layerSize.width/2, layerSize.height/2+10.0f);
    [pauseModeLayer addChild:btn];
    btn.tag=buttonplay;
    [menuButtons addObject:btn];
    
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"button-replay"]];
    btn.anchorPoint=ccp(1.0f, 1.0f);
    btn.position=ccp(layerSize.width/2-(btn.contentSize.width/2), layerSize.height/2-10.0f);
    [pauseModeLayer addChild:btn];
    btn.tag=buttonreplay;
    [menuButtons addObject:btn];
    
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"button-home"]];
    btn.anchorPoint=ccp(0.0f, 1.0f);
    btn.position=ccp(layerSize.width/2+(btn.contentSize.width/2), layerSize.height/2-10.0f);
    [pauseModeLayer addChild:btn];
    btn.tag=buttonhome;
    [menuButtons addObject:btn];
}

-(void)createAndShowPauseModeLayer{
    for (CCSprite *btn in menuButtons) {
        [btn removeFromParentAndCleanup:YES];
    }
    [menuButtons removeAllObjects];
    
    pauseModeLayer=[CCNodeColor nodeWithColor:[CCColor colorWithCcColor4b:ccc4(50.0f, 50.0f, 50.0f, 167.0f)] width:winSize.width height:winSize.height];
    [self addChild:pauseModeLayer z:100];
    
    [self addButtonsToPauseModeLayer];
}

-(BOOL)menuButtonClicked:(id)sender btn:(CCSprite *)btn{
//    NSLog(@"tag--->%d",btn.tag);
    
    if (btn.tag==buttonpause) {
        for (CCSprite *btn in menuButtons) {
            btn.visible=NO;
        }
        self.userInteractionEnabled=NO;
        [self.bikeSprite setPaused:YES];
        //self.isAccelerometerEnabled=NO;
        [self stopAllActions];
        [self setPaused:YES];
        for (RVRCoin *BPoint in movingBikerPoints) {
            [BPoint setPaused:YES];
        }
        for (RVRCoin *bPoint in self.collectedBikerPoints) {
            [bPoint.aliasCoin setPaused:YES];
        }
        for (CCSprite *child in [explosionBatchNode children]) {
            [child setPaused:YES];
        }
        [[RVRAudioManager sharedManager] playBikeEngineSound:NO];
        //[self createAndShowPauseModeLayer];
        [[PauseOrGameOverMenu menu] pauseMenu];
    }
    
    return NO;
}

-(void)bringGameOverMenu:(id)sender{
    for (CCSprite *btn in menuButtons) {
        btn.visible=NO;
    }
    self.userInteractionEnabled=NO;
    [self.bikeSprite setPaused:YES];
    //self.isAccelerometerEnabled=NO;
    [self stopAllActions];
    [self setPaused:YES];
    for (RVRCoin *BPoint in movingBikerPoints) {
        [BPoint setPaused:YES];
    }
    for (RVRCoin *bPoint in self.collectedBikerPoints) {
        [bPoint.aliasCoin setPaused:YES];
    }
    for (CCSprite *child in [explosionBatchNode children]) {
        [child setPaused:YES];
    }
    [[RVRAudioManager sharedManager] playBikeEngineSound:NO];
    //[self createAndShowPauseModeLayer];
    [[PauseOrGameOverMenu menu] gameOverMenu];
    
    if (((int64_t)distanceInMiles)>appDelegate.databaseManager.userData.myHighScore){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isGCScoreSubmitted"];
        appDelegate.databaseManager.highScoreChanged=YES;
        appDelegate.databaseManager.userData.myHighScore=((int64_t)distanceInMiles);
    }
}

#pragma MARK - PauseOrGameOverMenuBtnClickDelegate Methods Implementation
-(void)disableInvincibilityAfterRevive:(id)sender{
    self.isInvincible=NO;
}

-(void)buttonClickedWithTag:(int)tag{
    if(tag==resume){
        willBringGameOverMenu=NO;
        for (CCSprite *btn in menuButtons) {
            btn.visible=YES;
        }
        self.userInteractionEnabled=YES;
        [self.bikeSprite setPaused:NO];
        //self.isAccelerometerEnabled=YES;
        [self setPaused:NO];
        for (RVRCoin *BPoint in movingBikerPoints) {
            [BPoint setPaused:NO];
        }
        for (RVRCoin *bPoint in self.collectedBikerPoints) {
            [bPoint.aliasCoin setPaused:NO];
        }
        for (CCSprite *child in [explosionBatchNode children]) {
            [child setPaused:NO];
        }
        [[RVRAudioManager sharedManager] playBikeEngineSound:YES];
        //[self createMenuButtons];
    }
    else if(tag==revive){
        willBringGameOverMenu=NO;
        appDelegate.databaseManager.userData.uCoins-=1000;
        [appDelegate.gHud.coinsLabel setString:[NSString stringWithFormat:@"%d",appDelegate.databaseManager.userData.uCoins]];
        
        [self disableAllPowerUps];
        if (self.hasDoubleValuedCoins==YES) {
            waitingForResettingBikerPoints=YES;
        }
        shouldAlertForCollectableDisCovrd=NO;
        speedBeforeSSS=INITIALSPEED;
        distMsg.distanceForSuperSpeedyStarter=0.0f;
        self.bikeSprite.opacity=127.0f;
        self.isInvincible=YES;
        currentSpeed=MAXSPEED;
        
        for (CCSprite *btn in menuButtons) {
            btn.visible=YES;
        }
        self.bikeSprite.visible=YES;
        self.userInteractionEnabled=YES;
        [self.bikeSprite setPaused:NO];
        //self.isAccelerometerEnabled=YES;
        [self setPaused:NO];
        
        //cause after game over pause was called as a delegate!
        [self schedule:@selector(update:) interval:0];
        
        for (RVRCoin *BPoint in movingBikerPoints) {
            [BPoint setPaused:NO];
        }
        for (RVRCoin *bPoint in self.collectedBikerPoints) {
            [bPoint.aliasCoin setPaused:NO];
        }
        for (CCSprite *child in [explosionBatchNode children]) {
            [child setPaused:NO];
        }
        [[RVRAudioManager sharedManager] playBikeEngineSound:YES];
    }
    else if(tag==playagain){
        if (((int64_t)distanceInMiles)>appDelegate.databaseManager.userData.myHighScore){
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isGCScoreSubmitted"];
            appDelegate.databaseManager.highScoreChanged=YES;
            appDelegate.databaseManager.userData.myHighScore=((int64_t)distanceInMiles);
        }
        [[RVRAudioManager sharedManager] playBikeEngineSound:NO];
        [[CCDirector sharedDirector] replaceScene:[GameNode scene] withTransition:[CCTransition transitionFadeWithDuration:1.0f]];
    }
    else if(tag==mainmenu){
        if (((int64_t)distanceInMiles)>appDelegate.databaseManager.userData.myHighScore){
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isGCScoreSubmitted"];
            appDelegate.databaseManager.highScoreChanged=YES;
            appDelegate.databaseManager.userData.myHighScore=((int64_t)distanceInMiles);
        }
        [[RVRAudioManager sharedManager] playBikeEngineSound:NO];
        appDelegate.gamePlayRunning=NO;
        [[CCDirector sharedDirector] replaceScene:[GameMenu scene] withTransition:[CCTransition transitionFadeWithDuration:1.0f]];
    }
//    NSLog(@"distance --->%lld",((int64_t)distanceInMiles));
}

#pragma MARK - BatchNode And Animation Control Methods
-(void)loadExplosionBatchNode {
    explosionBNChilds=[[NSMutableArray alloc] init];
    
    CCTexture *texture=[((TextureManager*)[TextureManager sharedTextureManager]).batchTextures objectForKey:@"explosion"];
    NSMutableArray *spriteFrames=[NSMutableArray array];
    CGSize frameSize=CGSizeMake(texture.contentSize.width/EXPLOSIONXFRAMES, texture.contentSize.height/EXPLOSIONYFRAMES);
    
    
    
    
    
    explosionBatchNode=[CCSpriteBatchNode batchNodeWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).batchTextures objectForKey:@"explosion"]];
    explosionBatchNode.visible=NO;
    
    [self addChild:explosionBatchNode z:100];
    
    CGSize frameSize=CGSizeMake(explosionBatchNode.texture.contentSize.width/EXPLOSIONXFRAMES, explosionBatchNode.texture.contentSize.height/EXPLOSIONYFRAMES);
    //    NSLog(@"contentsize--->%f,%f",explosionBatchNode.textureAtlas.texture.contentSize.width,explosionBatchNode.textureAtlas.texture.contentSize.height);
    
    CCSprite *explosionSprite;
    for (int i=0; i<NOOFEXPLOSIONSPRITES; i++) {
        explosionSprite=[CCSprite spriteWithBatchNode:explosionBatchNode rect:CGRectMake(0, 0, frameSize.width, frameSize.height)];
        explosionSprite.visible=NO;
        
        [explosionBatchNode addChild:explosionSprite];
        
        [explosionBNChilds addObject:explosionSprite];
    }
    
    [[explosionSprite animationManager] animationWithSpriteFrames:<#(id)#> delay:<#(float)#> name:<#(NSString *)#> node:<#(CCNode *)#> loop:<#(BOOL)#>]
}

#pragma MARK - AnimationAction Methods
-(void)hideExplosionSprite:(CCSprite*)bullet{
    bullet.visible=NO;
    shootCount--;
}

-(void)animateExplosion:(CCSprite*)bullet {
    [[RVRAudioManager sharedManager] playExplosionSound];
	CCActionAnimate *explosion = [CCActionAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache]  animationByName:@"explosionAnim"] restoreOriginalFrame:YES];
    
    CCActionCallFuncO *callHideExplosionMthd=[CCActionCallFuncO actionWithTarget:self selector:@selector(hideExplosionSprite:) object:bullet];
    CCActionSequence *sequence=[CCActionSequence actions:explosion,callHideExplosionMthd, nil];
    
	[bullet runAction:sequence];
}

-(void)hideVehicle:(NSArray*)array{
    //[[RVRAudioManager sharedManager] playFiringSound:NO];
    NSNumber *num=[array objectAtIndex:0];
    NSInteger indx=[num intValue];
    
    Obstacles *vehicle=[movingVehicles objectAtIndex:indx];
    CCSprite *shootSprite=[array objectAtIndex:1];
    
    vehicle.visible=NO;
    
    [self animateExplosion:shootSprite];
}

-(BOOL)shootVehicle:(NSInteger)movingVIndx{
    Obstacles *vehicle=[movingVehicles objectAtIndex:movingVIndx];
    
    float xShift=self.bikeSprite.contentSize.height*sinf((PI/180.0f)*self.bikeSprite.rotation);
    float yShift=self.bikeSprite.contentSize.height*cosf((PI/180.0f)*self.bikeSprite.rotation);
    
    CCSprite *shootSprite=((CCSprite*)[explosionBNChilds objectAtIndex:shootCount++]);
    NSLog(@"shootcount--->%d",shootCount);
    float actionDuration=(0.5f/winSize.height)*ccpDistance(shootSprite.position, vehicle.position);
    
    float vTargetYShift=(vehicle.vehicleSpeed*actionDuration);
    
    if (self.isBikeAccelerating>0)
        vTargetYShift+=(0.5f*ACCELERATION*pow(actionDuration, 2));
    
    else if(self.isBikeAccelerating<0)
        vTargetYShift+=(0.5f*RETARDATION*pow(actionDuration, 2));
    
    shootSprite.position=CGPointMake(self.bikeSprite.position.x+xShift, self.bikeSprite.position.y+yShift);
    shootSprite.visible=YES;
    
    [[RVRAudioManager sharedManager] playFiringSound];
    CCMoveTo *fire=[CCMoveTo actionWithDuration:actionDuration position:CGPointMake(vehicle.position.x, vehicle.position.y-vehicle.contentSize.height-vTargetYShift)];
    
    NSArray *array=[NSArray arrayWithObjects:[NSNumber numberWithInt:movingVIndx],shootSprite, nil];
    
    //CCCallFuncO *hideV=[CCCallFuncO actionWithTarget:self selector:@selector(hideVehicle:) object:array];
    //CCSequence *sequence=[CCSequence actions:fire,hideV, nil];
    
    [shootSprite runAction:fire];
    [self performSelector:@selector(hideVehicle:) withObject:array afterDelay:actionDuration];
    return YES;
}

-(void)crushBike{
    CCSprite *shootSprite=((CCSprite*)[explosionBNChilds lastObject]);
    
    shootSprite.position=CGPointMake(self.bikeSprite.position.x, self.bikeSprite.position.y+self.bikeSprite.contentSize.height);
    shootSprite.visible=YES;
    
    self.bikeSprite.visible=NO;
    
    CCAnimate *explosion = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache]  animationByName:@"explosionAnim"] restoreOriginalFrame:YES];
    CCCallFuncO *callHideExplosionMthd=[CCCallFuncO actionWithTarget:self selector:@selector(hideExplosionSprite:) object:shootSprite];
    //CCCallFuncO *backToMenu=[CCCallFuncO actionWithTarget:[CCDirector sharedDirector] selector:@selector(replaceScene:) object:[CCTransitionFade transitionWithDuration:1.0f scene:[GameMenu scene]]];
    CCCallFunc *backToMenu=[CCCallFunc actionWithTarget:self selector:@selector(bringGameOverMenu:)];
    
    CCSequence *sequence=[CCSequence actions:explosion,callHideExplosionMthd,backToMenu, nil];
    
	[shootSprite runAction:sequence];
}
@end
