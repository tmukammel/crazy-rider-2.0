//
//  RootViewController.m
//  MotoRacer
//
//  Created by Twaha Mukammel on 5/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "RootViewController.h"
#import "GameConfig.h"
#import "RVRPowerUpsAndPurchasesStore.h"

@implementation RootViewController

@synthesize modalPresentationFrame,modalHiddenFrame;

-(NSUInteger)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate {
    return YES;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	//
	// Assuming that the main window has the size of the screen
	// BUG: This won't work if the EAGLView is not fullscreen
	///
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGRect rect = CGRectZero;

	
	if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)		
		rect = screenRect;
	
	else if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
		rect.size = CGSizeMake( screenRect.size.height, screenRect.size.width );
	
	CCDirector *director = [CCDirector sharedDirector];
	EAGLView *glView = [director openGLView];
	float contentScaleFactor = [director contentScaleFactor];
	
	if( contentScaleFactor != 1 ) {
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
	}
	glView.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)presentModalView:(RootViewController*)modalViewController withDelegate:(id)delegate selector:(SEL)selector animated:(BOOL)animated {
    if (animated) {
        //[[modalViewController.view superview] bringSubviewToFront:modalViewController.view];
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.5f];
        
        modalViewController.view.frame=modalViewController.modalPresentationFrame;
        [UIView setAnimationDelegate:delegate];
        [UIView setAnimationDidStopSelector:selector];
        
        [UIView commitAnimations];
    }
}

-(void)dismissModalViewAnimated:(BOOL)animated withDelegate:(id)delegate selector:(SEL)selector {
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        
        [UIView setAnimationDuration:0.5f];
        
        self.view.frame=self.modalHiddenFrame;
        [UIView setAnimationDelegate:delegate];
        [UIView setAnimationDidStopSelector:selector];
        
        [UIView commitAnimations];
    }
}

- (void)dealloc {
    [super dealloc];
}


@end

