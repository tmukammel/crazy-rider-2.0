//
//  GamePlayObserverDelegateProtocol.h
//  MotoRacer
//
//  Created by Twaha Mukammel on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GamePlayObserverDelegate <NSObject>
@optional
-(void)gamePlayStarted;
-(void)gamePlayStoped;
-(void)distanceCoveredFor:(int)tag;
-(void)newCollectablePowerUpAppearanceRequest;
-(void)collectablePowerUpCollected:(NSString*)key;
-(void)speedyStarterUsedWithTag:(NSString*)tag;
@end

@protocol ControllerMenu <NSObject>
@required
-(void)getBackControl;
@end
