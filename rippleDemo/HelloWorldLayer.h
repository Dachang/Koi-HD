//
//  main.m
//  Koi HD
//
//  Created by 大畅 on 13-5-9.
//  Copyright OceanDev 2013. All rights reserved.
//

#import "cocos2d.h"
#import "KOIRippleSprite.h"

#define FRAMETIME 0.08f  

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer {
    KOIRippleSprite* rippleImage;
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
