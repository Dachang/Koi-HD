//
//  HelloWorldLayer.h
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "pgeRippleSprite.h"

#define FRAMETIME 0.08f  

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer {
    pgeRippleSprite* rippleImage;
    CCSprite* fish;
    CCSprite* koi_tiny;
    CCSprite* koi_medium;
    CCSprite* koi_large;
    CCAction* action_gather;
    CCAction* action_fade;
    CCAction* action_fade_large;
    CCAction* action_gather_large;
//    int speed;
//    float randomSpeed;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
