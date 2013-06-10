//
//  HelloWorldLayer.m
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {

        // --------------------------------------------------------------------------
        // create ripple sprite
        // --------------------------------------------------------------------------

        // create koi animation
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        fish = [CCSprite spriteWithFile:@"fish3.png"];
        [fish setPosition:CGPointMake(winSize.width/2, winSize.height/2 - 50)];
        [fish setOpacity:100];
//        [ self addChild:fish z:1 tag:1];
        
        CCTexture2D* playRunTexture = [[CCTextureCache sharedTextureCache] addImage:@"koi_run.png"];
        NSMutableArray* animFrames = [[NSMutableArray alloc] init];
        for(int i = 0;i<8;i++)
        {
            [animFrames addObject:[CCSpriteFrame frameWithTexture:playRunTexture rect:CGRectMake(72*i, 0, 72, 72)]];
        }

        CCAnimation* animation = [[CCAnimation alloc] init];
        [animation initWithFrames:animFrames delay:0.15f];
        [animFrames release];
        
        CCAnimate *animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:false];
        koi = [CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithTexture:playRunTexture rect:CGRectMake(0, 0, 72, 72)]];

        [koi runAction:[CCRepeatForever actionWithAction:animate]];
        [koi setPosition:CGPointMake(winSize.width/2, winSize.height/2)];
        [self addChild:koi z:2];
        
        

        
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"background.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"water.wav"];
        
        rippleImage = [ pgeRippleSprite ripplespriteWithFile:@"BGHD.png" ];
        [ self addChild:rippleImage ];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background.wav" loop:YES];

        // --------------------------------------------------------------------------

        

        
        // enable touch
        [ [ CCTouchDispatcher sharedDispatcher ] addTargetedDelegate:self priority:0 swallowsTouches:YES ];	
        
        // schedule update
        [ self schedule:@selector( update: ) ];    
                
	}
	return self;
}

float runtime = 0;

-( BOOL )ccTouchBegan:( UITouch* )touch withEvent:( UIEvent* )event {
    runtime = 0.1f;
    [ self ccTouchMoved:touch withEvent:event ];
    [[SimpleAudioEngine sharedEngine] playEffect:@"water.wav"];
    return( YES );
}

-( void )ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pos;
    
    if ( runtime >= 0.1f ) {
        
        runtime -= 0.1f;
        
        // get touch position and convert to screen coordinates
        pos = [ touch locationInView: [ touch view ] ];
        pos = [ [ CCDirector sharedDirector ] convertToGL:pos ];
    
        // [ rippleImage addRipple:pos type:RIPPLE_TYPE_RUBBER strength:1.0f ];    
        [ rippleImage addRipple:pos type:RIPPLE_TYPE_WATER strength:2.0f ];
        
        //create koi rotation
        if((pos.x > koi.position.x) && (pos.y > koi.position.y))
        {
            koi.rotation = 25;
        }
        if((pos.x < koi.position.x) && (pos.y > koi.position.y))
        {
            koi.rotation = -90;
        }
        if((pos.x > koi.position.x) && (pos.y < koi.position.y))
        {
            koi.rotation = 90;
        }
        if((pos.x < koi.position.x) && (pos.y < koi.position.y))
        {
            koi.rotation = 180;
        }
        
        
        CCAction* action3 = [CCMoveTo actionWithDuration:10.0f position:pos];
        [koi runAction:action3];
    }
}

-(CCMoveTo*) actionWithDuration:(ccTime)duration pos:(CGPoint) position
{
    CCMoveTo* move_to = [[CCMoveTo alloc] initWithDuration: duration position: position];
    return move_to;
}

//-(int)getRandomNumber:(int)from to:(int)to
//
//{
//    return (from + (arc4random() % (to - from + 1)));
//}


-( void )update:( ccTime )dt {
    
    runtime += dt;
    
//    speed = [self getRandomNumber:10 to:21];
//    NSLog(@"%d",speed);
    [ rippleImage update:dt ];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
