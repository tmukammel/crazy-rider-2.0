//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    MainScene *gameMenu = [MainScene node];
    //appDelegate.gMenu=gameMenu;
    
    // add layer as a child to scene
    [scene addChild: gameMenu];
    
    // return the scene
    return scene;
}

@end
