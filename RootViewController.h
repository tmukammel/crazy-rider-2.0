//
//  RootViewController.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 5/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RootViewController : UINavigationController {

}

@property (nonatomic,readwrite) CGRect modalPresentationFrame,modalHiddenFrame;

-(void)presentModalView:(RootViewController*)modalViewController withDelegate:(id)delegate selector:(SEL)selector animated:(BOOL)animated;
-(void)dismissModalViewAnimated:(BOOL)animated withDelegate:(id)delegate selector:(SEL)selector;

@end
