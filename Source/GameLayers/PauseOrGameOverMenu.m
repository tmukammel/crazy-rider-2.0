//
//  PauseOrGameOverMenu.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PauseOrGameOverMenu.h"
#import "AppController.h"
#import "cocos2d.h"
#import "RVRPowerUpsAndPurchasesStore.h"
#import "GameNode.h"
#import "RVRAudioManager.h"

static PauseOrGameOverMenu *pauseOrGameOverMenu=nil;

@interface PauseOrGameOverMenu (Private)
-(void)initiateSelf;
-(void)initiatePauseMenu;
-(void)initiateGameOverMenu;
-(void)buttonClicked:(id)sender;
@end

@implementation PauseOrGameOverMenu

@synthesize delegate,reqSent;

enum{
    nothingBtn=0,
    resume=1,
    revive=2,
    playagain=3,
    store=4,
    mainmenu=5,
    scoreLabel=6,
};

-(id)init{
    if ((self=[super init])) {
        appDelegate=[[UIApplication sharedApplication] delegate];
        winSize=[[CCDirector sharedDirector] winSize];
        
        [self initiateSelf];
        [self initiatePauseMenu];
        [self initiateGameOverMenu];
    }
    return self;
}

+(id)menu{
    if (pauseOrGameOverMenu==nil) {
        pauseOrGameOverMenu=[[self alloc] init];
    }
    return pauseOrGameOverMenu;
}

-(void)pauseMenu{
    pauseMenuView.hidden=NO;
    [self.view bringSubviewToFront:pauseMenuView];
    [appDelegate.viewController presentModalView:self withDelegate:nil selector:nil animated:YES];
}

-(void)gameOverMenu{
    reqSent=NO;
    gameOverMenuView.hidden=NO;
    if (((GameNode*)appDelegate.gNode).gameOverCount>1) {
        [gameOverMenuView viewWithTag:revive].hidden=YES;
    }
    else
        [gameOverMenuView viewWithTag:revive].hidden=NO;
    ((UILabel*)[gameOverMenuView viewWithTag:scoreLabel]).text=[NSString stringWithFormat:@"Your Score: %0.2f",appDelegate.gNode.distanceInMiles];
    [self.view bringSubviewToFront:gameOverMenuView];
    [appDelegate.viewController presentModalView:self withDelegate:nil selector:nil animated:YES];
}

-(void)initiateSelf{
    self.view.frame=self.modalHiddenFrame=CGRectMake(0.0f, -winSize.height, winSize.width, winSize.height);
    self.modalPresentationFrame=CGRectMake(0.0f, 0.0f, winSize.width, winSize.height);
    self.view.backgroundColor=[UIColor clearColor];
    self.view.opaque=NO;
    
    [appDelegate.viewController.view addSubview:self.view];
    [appDelegate.viewController.view sendSubviewToBack:self.view];
}

-(void)initiatePauseMenu{
    CGSize size;
    float yShift;
    float shift;
    
    pauseMenuView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    pauseMenuView.opaque=NO;
    pauseMenuView.backgroundColor=[UIColor clearColor];
    pauseMenuView.hidden=YES;
    
    UIImageView *back=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pause-menu-bg.png"]] autorelease];
    back.backgroundColor=[UIColor clearColor];
    back.opaque=NO;
    back.frame=CGRectMake(winSize.width/8.0f, (pauseMenuView.frame.size.height-back.frame.size.height)/2.0f, back.frame.size.width, back.frame.size.height);
    [pauseMenuView addSubview:back];
    
    UIButton *resumeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [resumeBtn setImage:[UIImage imageNamed:@"btn-resume.png"] forState:UIControlStateNormal];
    
    size=CGSizeMake(152.0f, 48.0f);
    yShift=(back.frame.size.height-(size.height*3.0f))/4.0f;
    
    resumeBtn.frame=CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+yShift, size.width, size.height);
    resumeBtn.bounds=CGRectMake(0.0f, 0.0f, size.width, size.height);
    [resumeBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    resumeBtn.tag=resume;
    [pauseMenuView addSubview:resumeBtn];
    
    UIButton *playAgainBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [playAgainBtn setImage:[UIImage imageNamed:@"btn-play-again.png"] forState:UIControlStateNormal];
    
    size=CGSizeMake(152.0f, 48.0f);
    shift=(yShift*2)+resumeBtn.frame.size.height;
    
    playAgainBtn.frame=CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+shift, size.width, size.height);
    playAgainBtn.bounds=CGRectMake(0.0f, 0.0f, size.width, size.height);
    [playAgainBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    playAgainBtn.tag=playagain;
    [pauseMenuView addSubview:playAgainBtn];
    
    UIButton *mainMenuBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [mainMenuBtn setImage:[UIImage imageNamed:@"btn-main-menu.png"] forState:UIControlStateNormal];
    
    size=CGSizeMake(152.0f, 48.0f);
    shift=(yShift*3)+playAgainBtn.frame.size.height+resumeBtn.frame.size.height;
    
    mainMenuBtn.frame=CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+shift, size.width, size.height);
    mainMenuBtn.bounds=CGRectMake(0.0f, 0.0f, size.width, size.height);
    [mainMenuBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    mainMenuBtn.tag=mainmenu;
    [pauseMenuView addSubview:mainMenuBtn];
    
    [self.view addSubview:pauseMenuView];
    [self.view sendSubviewToBack:pauseMenuView];
}

-(void)initiateGameOverMenu{
    CGSize size;
    float yShift=90.0f;
    float shift;
    float difConst;
    
    gameOverMenuView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    gameOverMenuView.opaque=NO;
    gameOverMenuView.backgroundColor=[UIColor clearColor];
    gameOverMenuView.hidden=YES;
    
    UIImageView *back=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"game-over-bg.png"]] autorelease];
    back.backgroundColor=[UIColor clearColor];
    back.opaque=NO;
    back.frame=CGRectMake(winSize.width/8.0f, (gameOverMenuView.frame.size.height-back.frame.size.height)/2.0f, back.frame.size.width, back.frame.size.height);
    [gameOverMenuView addSubview:back];
    
    UIButton *reviveBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [reviveBtn setImage:[UIImage imageNamed:@"btn-revive.png"] forState:UIControlStateNormal];
    
    size=CGSizeMake(152.0f, 48.0f);
    difConst=(back.frame.size.height-(yShift+(size.height*4.0f)))/5.0f;
    shift=yShift+difConst;
    
    reviveBtn.frame=CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+shift-2.0f, size.width, size.height);
    reviveBtn.bounds=CGRectMake(0.0f, 0.0f, size.width, size.height);
    [reviveBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    reviveBtn.tag=revive;
    [gameOverMenuView addSubview:reviveBtn];
    
    UIButton *playAgainBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [playAgainBtn setImage:[UIImage imageNamed:@"btn-play-again.png"] forState:UIControlStateNormal];
    
    size=CGSizeMake(152.0f, 48.0f);
    shift+=reviveBtn.frame.size.height+difConst;
    
    playAgainBtn.frame=CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+shift, size.width, size.height);
    playAgainBtn.bounds=CGRectMake(0.0f, 0.0f, size.width, size.height);
    [playAgainBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    playAgainBtn.tag=playagain;
    [gameOverMenuView addSubview:playAgainBtn];
    
    UIButton *storeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [storeBtn setImage:[UIImage imageNamed:@"btn-store.png"] forState:UIControlStateNormal];
    
    size=CGSizeMake(152.0f, 48.0f);
    shift+=playAgainBtn.frame.size.height+difConst;
    
    storeBtn.frame=CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+shift, size.width, size.height);
    storeBtn.bounds=CGRectMake(0.0f, 0.0f, size.width, size.height);
    [storeBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    storeBtn.tag=store;
    [gameOverMenuView addSubview:storeBtn];
    
    UIButton *mainMenuBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [mainMenuBtn setImage:[UIImage imageNamed:@"btn-main-menu.png"] forState:UIControlStateNormal];
    
    size=CGSizeMake(152.0f, 48.0f);
    shift+=storeBtn.frame.size.height+difConst;
    
    mainMenuBtn.frame=CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+shift, size.width, size.height);
    mainMenuBtn.bounds=CGRectMake(0.0f, 0.0f, size.width, size.height);
    [mainMenuBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    mainMenuBtn.tag=mainmenu;
    [gameOverMenuView addSubview:mainMenuBtn];
    
    UILabel *nowScored=[[[UILabel alloc] initWithFrame:CGRectMake(back.frame.origin.x+(back.frame.size.width-size.width)/2.0f, back.frame.origin.y+35.0f, size.width, size.height)] autorelease];
    nowScored.text=@"";
    nowScored.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:25];
    nowScored.adjustsFontSizeToFitWidth = YES;
    nowScored.textAlignment=UITextAlignmentCenter;
    nowScored.textColor=[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
    nowScored.backgroundColor=[UIColor clearColor];
    nowScored.opaque=NO;
    nowScored.tag=scoreLabel;
    [gameOverMenuView addSubview:nowScored];
    
    [self.view addSubview:gameOverMenuView];
    [self.view sendSubviewToBack:gameOverMenuView];
}

-(void)buttonClicked:(id)sender{
    if (self.delegate!=nil) {
        [[RVRAudioManager sharedManager] playButtonClickSound:YES];
        if ([sender tag]==revive) {
            if (appDelegate.databaseManager.userData.uCoins>=1000) {
                btnClickedTag=[sender tag];
                [self dismissModalViewAnimated:YES withDelegate:self selector:@selector(uiViewAnimaitonDidFinish:)];
            }
            else{
                UIAlertView* alert= [[[UIAlertView alloc] initWithTitle:@"Coin!" message:@"You do not have Enough Coins. Buy More Coins!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NULL] autorelease];
                [alert show];
            }
        }
        else{
            btnClickedTag=[sender tag];
            [self dismissModalViewAnimated:YES withDelegate:self selector:@selector(uiViewAnimaitonDidFinish:)];
        }
        
    }
}

-(void)uiViewAnimaitonDidFinish:(id)sender{
    if (btnClickedTag==resume) {
        [self.delegate buttonClickedWithTag:resume];
    }
    else if (btnClickedTag==playagain) {
        [self.delegate buttonClickedWithTag:playagain];
    }
    else if (btnClickedTag==mainmenu) {
        [self.delegate buttonClickedWithTag:mainmenu];
    }
    else if(btnClickedTag==store){
        reqSent=YES;
        [appDelegate.viewController presentModalView:[RVRPowerUpsAndPurchasesStore powerUpsAndPurchaseStore] withDelegate:nil selector:nil animated:YES];
    }
    else if(btnClickedTag==revive){
        [self.delegate buttonClickedWithTag:revive];
    }
    btnClickedTag=nothingBtn;
    pauseMenuView.hidden=YES;
    gameOverMenuView.hidden=YES;
}

-(void)dealloc{
    [pauseOrGameOverMenu release];
    [pauseMenuView release];
    pauseMenuView=nil;
    [gameOverMenuView release];
    gameOverMenuView=nil;
    
    [super dealloc];
}
@end
