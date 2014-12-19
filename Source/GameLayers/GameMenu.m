//
//  GameMenu.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 6/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameMenu.h"
#import "TextureManager.h"
#import "GameNode.h"
#import "PauseOrGameOverMenu.h"
#import "GameCenterDelegate.h"
#import "RVRInAppPurchaseStore.h"
#import "RVRAudioManager.h"

enum{
    nothing,
    ride,
    store,
    customize,
    highScore,
    gameCenter,
    audioButton,
};

@interface GameMenu (Private)
-(void)setUpBackground;
-(void)createButtons;
-(void)setAudioButton;
-(void)addGlowBackForBtn:(CCSprite*)btn;
-(void)moveButtonsIntoScreen:(NSNumber*)indx;
-(void)moveButtonsOutofScreen:(NSNumber *)indx;
-(void)buttonsMovedOutOfScreen:(id)sender;
-(BOOL)menuButtonClicked:(id)sender btn:(CCSprite*)btn;
-(void)showHideGlowBtnAtIndx:(NSArray*)array;
-(void)loadAllPreloadableViews;
-(void)makeMenuInteractable:(NSNumber*)isInteractable;
-(void)updateDataForLastGamePlay;
@end

@implementation GameMenu

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    // 'layer' is an autorelease object.
	GameMenu *gameMenu = [GameMenu node];
	//appDelegate.gMenu=gameMenu;
    
	// add layer as a child to scene
	[scene addChild: gameMenu];
    
	// return the scene
	return scene;
}

-(id)init{
    if (self=[super init]) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] winSize];
        
        self.isTouchEnabled=YES;
        
        btnGlows=[[NSMutableArray alloc] init];
        menuButtons=[[NSMutableArray alloc] init];
        [self setUpBackground];
        [self setAudioButton];
        [self createButtons];
        [self loadAllPreloadableViews];
        
        gcDelegate=[GameCenterDelegate sharedGameCenterDelegate];
        [gcDelegate setDelegate:self];
        if (appDelegate.databaseManager.highScoreChanged==YES) {
            appDelegate.databaseManager.highScoreChanged=NO;
            [self updateDataForLastGamePlay];
        }
        
        [self performSelector:@selector(moveButtonsIntoScreen:) withObject:[NSNumber numberWithInt:1] afterDelay:0.50f];
        [[RVRAudioManager sharedManager] playBGMusic:YES];
    }
    return self;
}

-(void)updateDataForLastGamePlay{
    BOOL isSubmitted=[[NSUserDefaults standardUserDefaults] boolForKey:@"isGCScoreSubmitted"];
    if (isSubmitted==NO && gcDelegate.isGameCenterAuthOnce==YES) {
        [gcDelegate setCurrentScore:appDelegate.databaseManager.userData.myHighScore];
        [gcDelegate submitHighScore];
    }
}

-(void)setUpBackground{
    CCSprite *menuBack=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"mainMenuBackTexture"]];
    menuBack.position=ccp(winSize.width/2.0f, winSize.height/2.0f);
    [self addChild:menuBack];
}

-(void)setAudioButton{
    BOOL isMuted=[[NSUserDefaults standardUserDefaults] boolForKey:@"soundState"];
    if (isMuted==YES){
        if (audioBtn==nil)
            audioBtn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"music-off"]];
        else if(audioBtn!=nil)
            [audioBtn setTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"music-off"]];
    }
    else if(isMuted==NO){
        if (audioBtn==nil)
            audioBtn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"music-on"]];
        else if(audioBtn!=nil)
            [audioBtn setTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"music-on"]];
    }
    if (audioBtn!=nil && audioBtnAdded==NO) {
        audioBtnAdded=YES;
        audioBtn.anchorPoint=ccp(0.5f, 0.5f);
        audioBtn.position=ccp(winSize.width-(audioBtn.contentSize.width/2.0f)-5.0f, winSize.height-(audioBtn.contentSize.height/2.0f)-5.0f);
        audioBtn.tag=audioButton;
        [self addChild:audioBtn];
        [menuButtons addObject:audioBtn];
    }
}

-(void)makeMenuInteractable:(NSNumber*)isInteractable{
    BOOL value=[isInteractable boolValue];
    self.isTouchEnabled=value;
}

-(void)addGlowBackForBtn:(CCSprite *)btn{
    CCSprite *btnGlow=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"storeBTNglow"]];
    
    btnGlow.anchorPoint=ccp(0.0f, 0.5f);
    btnGlow.position=ccp(btn.position.x-btn.contentSize.width, btn.position.y);
    btnGlow.visible=NO;
    
    [self addChild:btnGlow];
    
    [btnGlows addObject:btnGlow];
}

-(void)createButtons{
    CGPoint prevPos;
    CCSprite *btn;
    
    float startOffset=(winSize.height/3.0f)*2.0f;
    
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"rideBTNTexture"]];
    
    float yOffsetFromTop=((winSize.height/3.0f)-btn.contentSize.height*NOOFBTNS)/(NOOFBTNS+1);
    
    //btn.anchorPoint=ccp(0.0f, 0.5f);
    //btn.position=ccp(winSize.width, winSize.height-yOffsetFromTop-(btn.contentSize.height/2));
    btn.anchorPoint=ccp(0.5f, 0.5f);
    btn.position=ccp(winSize.width+(btn.contentSize.width/2.0f), winSize.height-yOffsetFromTop-(btn.contentSize.height/2.0f)-startOffset);
    prevPos=btn.position;
    //[self addGlowBackForBtn:btn];
    [self addChild:btn];
    btn.tag=ride;
    [menuButtons addObject:btn];
    
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"storeBTNTexture"]];
    //btn.anchorPoint=ccp(0.0f, 0.5f);
    //btn.position=ccp(winSize.width, prevPos.y-yOffsetFromTop-btn.contentSize.height);
    btn.anchorPoint=ccp(0.5f, 0.5f);
    btn.position=ccp(-(btn.contentSize.width/2.0f), prevPos.y-yOffsetFromTop-btn.contentSize.height);
    prevPos=btn.position;
    //[self addGlowBackForBtn:btn];
    [self addChild:btn];
    btn.tag=store;
    [menuButtons addObject:btn];
    /*
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"customizeBTNTexture"]];
    //btn.anchorPoint=ccp(0.0f, 0.5f);
    //btn.position=ccp(winSize.width, prevPos.y-yOffsetFromTop-btn.contentSize.height);
    btn.anchorPoint=ccp(0.5f, 0.5f);
    btn.position=ccp(winSize.width+(btn.contentSize.width/2.0f), prevPos.y-yOffsetFromTop-btn.contentSize.height);
    prevPos=btn.position;
    //[self addGlowBackForBtn:btn];
    [self addChild:btn];
    btn.tag=customize;
    [menuButtons addObject:btn];
    
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"highScoreBTNTexture"]];
    //btn.anchorPoint=ccp(0.0f, 0.5f);
    //btn.position=ccp(winSize.width, prevPos.y-yOffsetFromTop-btn.contentSize.height);
    btn.anchorPoint=ccp(0.5f, 0.5f);
    btn.position=ccp(-(btn.contentSize.width/2.0f), prevPos.y-yOffsetFromTop-btn.contentSize.height);
    prevPos=btn.position;
    //[self addGlowBackForBtn:btn];
    [self addChild:btn];
    btn.tag=highScore;
    [menuButtons addObject:btn];
    */
    btn=[CCSprite spriteWithTexture:[((TextureManager*)[TextureManager sharedTextureManager]).allTextures objectForKey:@"gcBTNTexture"]];
    //btn.anchorPoint=ccp(0.0f, 0.5f);
    //btn.position=ccp(winSize.width, prevPos.y-yOffsetFromTop-btn.contentSize.height);
    btn.anchorPoint=ccp(0.5f, 0.5f);
    btn.position=ccp(winSize.width+(btn.contentSize.width/2.0f), prevPos.y-yOffsetFromTop-btn.contentSize.height);
    //[self addGlowBackForBtn:btn];
    [self addChild:btn];
    btn.tag=gameCenter;
    [menuButtons addObject:btn];
    
}

-(void)loadAllPreloadableViews{
    //loading store...
    RVRPowerUpsAndPurchasesStore *store=[RVRPowerUpsAndPurchasesStore powerUpsAndPurchaseStore];
    [store setControllerMenu:self];
    
    //loading PauseOrGameOverMenu...
    [PauseOrGameOverMenu menu];
    
    //loading InAppPurchase store...
    [RVRInAppPurchaseStore inAppStore];
}

-(void)moveButtonsIntoScreen:(NSNumber *)indx{
    CCSequence *sequence=nil;
    CCCallFuncO *nextCall=nil;
    
    int index=[indx intValue];
    CCSprite *btn=[menuButtons objectAtIndex:index];
    CCMoveTo *moveTo;
    //moveTo=[CCMoveTo actionWithDuration:0.1f position:CGPointMake(btn.position.x-btn.contentSize.width, btn.position.y)];
    moveTo=[CCMoveTo actionWithDuration:0.1f position:CGPointMake(winSize.width/2.0f, btn.position.y)];
    
    
    indx=[NSNumber numberWithInt:++index];
    if ([indx intValue]<[menuButtons count])
        nextCall=[CCCallFuncO actionWithTarget:self selector:@selector(moveButtonsIntoScreen:) object:indx];
    else
        nextCall=[CCCallFuncO actionWithTarget:self selector:@selector(makeMenuInteractable:) object:[NSNumber numberWithBool:YES]];
    
    sequence=[CCSequence actions:moveTo, nextCall, nil];
    
    [btn runAction:sequence];
}

-(void)uiViewAnimaitonDidFinish{
    NSLog(@"stopped");
}

-(void)moveButtonsOutofScreen:(NSNumber *)indx{
    CCSequence *sequence=nil;
    CCCallFuncO *nextCall=nil;
    
    int index=[indx intValue];
    CCSprite *btn=[menuButtons objectAtIndex:index];
    CCMoveTo *moveTo;
    //moveTo=[CCMoveTo actionWithDuration:0.1f position:CGPointMake(winSize.width, btn.position.y)];
    
    if ([indx intValue]%2==1) {
        moveTo=[CCMoveTo actionWithDuration:0.1f position:CGPointMake(winSize.width+(btn.contentSize.width/2.0f), btn.position.y)];
    }
    else{
        moveTo=[CCMoveTo actionWithDuration:0.1f position:CGPointMake(-(btn.contentSize.width/2.0f), btn.position.y)];
    }
    
    indx=[NSNumber numberWithInt:--index];
    if ([indx intValue]>0)
        nextCall=[CCCallFuncO actionWithTarget:self selector:@selector(moveButtonsOutofScreen:) object:indx];
    
    else
        nextCall=[CCCallFuncO actionWithTarget:self selector:@selector(buttonsMovedOutOfScreen:) object:self];
    
    sequence=[CCSequence actions:moveTo, nextCall, nil];
    
    [btn runAction:sequence];
}

-(void)buttonsMovedOutOfScreen:(id)sender{
    [self menuButtonClicked:self btn:clickedBtnRefKeeper];
    clickedBtnRefKeeper=nil;
}

-(BOOL)menuButtonClicked:(id)sender btn:(CCSprite*)btn{
    if (btn.tag==ride) {
        [[RVRAudioManager sharedManager] playBGMusic:NO];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameNode scene]]];
        return YES;
    }
    else if(btn.tag==store){
        [appDelegate.viewController presentModalView:[RVRPowerUpsAndPurchasesStore powerUpsAndPurchaseStore] withDelegate:nil selector:nil animated:YES];
        return YES;
    }
    else if(btn.tag==gameCenter){
        if (gcDelegate.isGameCenterAvailable==YES) {
            //[gcDelegate.gameCenterManager authenticateLocalUser];
            
            [gcDelegate showLeaderboard];
        }
    }
    else if(btn.tag==audioButton){
        BOOL isMuted=[[NSUserDefaults standardUserDefaults] boolForKey:@"soundState"];
        if (isMuted==YES) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"soundState"];
        }
        else if(isMuted==NO){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"soundState"];
        }
        [self setAudioButton];
        [[RVRAudioManager sharedManager] muteAll:!isMuted];
    }
    return NO;
}

-(void)showHideGlowBtnAtIndx:(NSArray *)array{
    NSNumber *indx=[array objectAtIndex:0];
    NSNumber *show=[array objectAtIndex:1];
    
    ((CCSprite*)[btnGlows objectAtIndex:[indx intValue]]).visible=[show boolValue];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    for (CCSprite *btn in menuButtons) {
        if (CGRectContainsPoint([btn boundingBox], location)) {
            //CCScaleTo *YScale=[CCScaleTo actionWithDuration:0.000f scaleX:1.0f scaleY:1.35f];
            CCScaleTo *YScale=[CCScaleTo actionWithDuration:0.000f scaleX:1.0f scaleY:1.15f];
            //CCCallFuncO *showHideGlow=[CCCallFuncO actionWithTarget:self selector:@selector(showHideGlowBtnAtIndx:) object:[NSArray arrayWithObjects:[NSNumber numberWithInt:[menuButtons indexOfObject:btn]], [NSNumber numberWithBool:YES], nil]];
            CCSequence *sequence=[CCSequence actions:YScale, /*showHideGlow,*/ nil];
            [btn runAction:sequence];
            clickedButtonTag=btn.tag;
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    for (CCSprite *btn in menuButtons) {
        CCScaleTo *YScale=nil;
        //CCCallFuncO *showHideGlow=nil;
        CCCallFuncO *buttonsHideCall=nil,*touchDisableCall=nil;
        CCSequence *sequence=nil;
        BOOL isSeqSeq=NO;
        if(btn.scaleY!=1.0f){
            YScale=[CCScaleTo actionWithDuration:0.000f scaleX:1.0f scaleY:1.0f];
            //showHideGlow=[CCCallFuncO actionWithTarget:self selector:@selector(showHideGlowBtnAtIndx:) object:[NSArray arrayWithObjects:[NSNumber numberWithInt:[menuButtons indexOfObject:btn]], [NSNumber numberWithBool:NO], nil]];
        }
        if (CGRectContainsPoint([btn boundingBox], location) && btn.tag==clickedButtonTag) {
            clickedBtnRefKeeper=btn;
            if (btn.tag==ride || btn.tag==store || btn.tag==gameCenter){
                [[RVRAudioManager sharedManager] playButtonClickSound:YES];
                isSeqSeq=YES;
                NSNumber *maxIndx=[NSNumber numberWithInt:[menuButtons count]-1];
                buttonsHideCall=[CCCallFuncO actionWithTarget:self selector:@selector(moveButtonsOutofScreen:) object:maxIndx];
                //[self makeMenuInteractable:[NSNumber numberWithBool:NO]];
                touchDisableCall=[CCCallFuncO actionWithTarget:self selector:@selector(makeMenuInteractable:) object:[NSNumber numberWithBool:NO]];
            }
            else if(btn.tag==audioButton){
                [[RVRAudioManager sharedManager] playButtonClickSound:YES];
                [self menuButtonClicked:self btn:clickedBtnRefKeeper];
                clickedBtnRefKeeper=nil;
            }
        }
        if (isSeqSeq==YES) {
            if (YScale==nil) {
                sequence=[CCSequence actions:touchDisableCall, buttonsHideCall, nil];
            }
            else
                sequence=[CCSequence actions:touchDisableCall, YScale, buttonsHideCall, nil];
        }
        else
            sequence=[CCSequence actions:YScale, /*showHideGlow,*/ buttonsHideCall, nil];
        if (sequence!=nil) {
            [btn runAction:sequence];
            break;
        }
    }
    clickedButtonTag=nothing;
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    for (CCSprite *btn in menuButtons) {
        if (CGRectContainsPoint([btn boundingBox], location)) {
            //CCScaleTo *YScale=[CCScaleTo actionWithDuration:0.000f scaleX:1.0f scaleY:1.35f];
            CCScaleTo *YScale=[CCScaleTo actionWithDuration:0.000f scaleX:1.0f scaleY:1.15f];
            //CCCallFuncO *showHideGlow=[CCCallFuncO actionWithTarget:self selector:@selector(showHideGlowBtnAtIndx:) object:[NSArray arrayWithObjects:[NSNumber numberWithInt:[menuButtons indexOfObject:btn]], [NSNumber numberWithBool:YES], nil]];
            CCSequence *sequence=[CCSequence actions:YScale, /*showHideGlow,*/ nil];
            [btn runAction:sequence];
        }
        else if(btn.scaleY!=1.0f){
            CCScaleTo *YScale=[CCScaleTo actionWithDuration:0.000f scaleX:1.0f scaleY:1.0f];
            //CCCallFuncO *showHideGlow=[CCCallFuncO actionWithTarget:self selector:@selector(showHideGlowBtnAtIndx:) object:[NSArray arrayWithObjects:[NSNumber numberWithInt:[menuButtons indexOfObject:btn]], [NSNumber numberWithBool:NO], nil]];
            CCSequence *sequence=[CCSequence actions:YScale, /*showHideGlow,*/ nil];
            [btn runAction:sequence];
        }
    }
}

-(void)dealloc{
    [menuButtons removeAllObjects];
    menuButtons=nil;
    [btnGlows removeAllObjects];
    btnGlows=nil;
    for (CCNode *child in self.children) {
        [[CCActionManager sharedManager] removeAllActionsFromTarget:child];
    }
    [super dealloc];
}

#pragma MARK - Delegate Methods
-(void)getBackControl{
    [self moveButtonsIntoScreen:[NSNumber numberWithInt:1]];
}

@end