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
        
        CCTexture2D* MediumKoiRunTexture = [[CCTextureCache sharedTextureCache] addImage:@"koi_run.png"];
        NSMutableArray* MediumKoiAnimFrames = [[NSMutableArray alloc] init];
        for(int i = 0;i<8;i++)
        {
            [MediumKoiAnimFrames addObject:[CCSpriteFrame frameWithTexture:MediumKoiRunTexture rect:CGRectMake(72*i, 0, 72, 72)]];
        }
        
        CCTexture2D* LargeKoiRunTexture = [[CCTextureCache sharedTextureCache] addImage:@"koi_run_Large.png"];
        NSMutableArray *LargeKoiAnimFrames = [[NSMutableArray alloc] init];
        for (int i = 0; i<4; i++)
        {
            [LargeKoiAnimFrames addObject:[CCSpriteFrame frameWithTexture:LargeKoiRunTexture rect:CGRectMake(144*i, 0, 144, 144)]];
        }

        CCAnimation* animation = [[CCAnimation alloc] init];
        [animation initWithFrames:animFrames delay:0.15f];
        [animFrames release];
        
        CCAnimation* MediumKoiAnimation = [[CCAnimation alloc] init];
        [MediumKoiAnimation initWithFrames:MediumKoiAnimFrames delay:0.15f];
        [MediumKoiAnimation release];
        
        CCAnimation* LargeKoiAnimation =[[CCAnimation alloc] init];
        [LargeKoiAnimation initWithFrames:LargeKoiAnimFrames delay:0.15f];
        [LargeKoiAnimFrames release];
        
        CCAnimate *animate = [CCAnimate actionWithAnimation:animation restoreOriginalFrame:false];
        CCAnimate *MediumKoiAnimate = [CCAnimate actionWithAnimation:MediumKoiAnimation restoreOriginalFrame:false];
        
        koi_tiny = [CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithTexture:playRunTexture rect:CGRectMake(0, 0, 72, 72)]];
        koi_medium = [CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithTexture:MediumKoiRunTexture rect:CGRectMake(0, 0, 72, 72)]];
        
        CCAnimate *LargeKoiAnimate = [CCAnimate actionWithAnimation:LargeKoiAnimation restoreOriginalFrame:false];
        koi_large = [CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithTexture:LargeKoiRunTexture rect:CGRectMake(0, 0, 144, 144)]];
        

        [koi_tiny runAction:[CCRepeatForever actionWithAction:animate]];
        [koi_tiny setPosition:CGPointMake(winSize.width/2, winSize.height/2)];
        [self addChild:koi_tiny z:2];
        
        [koi_large runAction:[CCRepeatForever actionWithAction:LargeKoiAnimate]];
        [koi_large setPosition:CGPointMake(500, 500)];
        [self addChild:koi_large z:3];
        
        [koi_medium runAction:[CCRepeatForever actionWithAction:MediumKoiAnimate]];
        [koi_medium setPosition:CGPointMake(200, 600)];
//        [self addChild:koi_medium z:4];
        
        

        // load ripple texture pool & sound effects & background music
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"background.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"water.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"wave.mp3"];
        
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
    [[SimpleAudioEngine sharedEngine] playEffect:@"wave.mp3"];
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
        
        
        if([self checkKoiDistance:koi_tiny atPosition:pos] || [self checkKoiDistance:koi_tiny atPosition:pos])
        {
            [self checkKoiRotation:koi_tiny atPostion:pos];
            [self checkKoiLargeRotation:koi_large atPostion:pos];
        }
                
        action_fade = [CCMoveTo actionWithDuration:3.0f position:ccp(72, 72)];
        action_gather = [CCMoveTo actionWithDuration:10.0f position:pos];
        
        action_fade_large = [CCMoveTo actionWithDuration:5.0f position:ccp(600, 900)];
        action_gather_large = [CCMoveTo actionWithDuration:8.0f position:pos];
        
        if (((pos.x - koi_tiny.position.x)*(pos.x - koi_tiny.position.x) < 900) && ((pos.y - koi_tiny.position.y)*(pos.y - koi_tiny.position.y) < 900))
        {
            if(((pos.x - koi_large.position.x)*(pos.x - koi_large.position.x) < 900) && ((pos.y - koi_large.position.y)*(pos.y - koi_large.position.y) < 900))
            {
                koi_large.rotation = 0;
                [koi_large runAction:action_fade_large];
                [koi_large setPosition:ccp(600, 900)];
                
                koi_tiny.rotation = 180;
                [koi_tiny runAction:action_fade];
                [koi_tiny setPosition:ccp(72, 72)];
            }
            else
            {
                koi_tiny.rotation = 180;
                [koi_tiny runAction:action_fade];
                [koi_tiny setPosition:ccp(72, 72)];
            }

        }
        else
        {
            if(((pos.x - koi_large.position.x)*(pos.x - koi_large.position.x) < 900) && ((pos.y - koi_large.position.y)*(pos.y - koi_large.position.y) < 900))
            {
                koi_large.rotation = 0;
                [koi_large runAction:action_fade_large];
                [koi_large setPosition:ccp(600, 900)];
            }
            else
            {
                [koi_large runAction:action_gather_large];
                [koi_tiny runAction:action_gather];
            }
        }
        NSLog(@"%f,%f",koi_large.position.x,koi_large.position.y);
        NSLog(@"%f,%f",pos.x,pos.y);

    }
}

-(void) checkKoiRotation:(CCSprite*) koi atPostion:(CGPoint) pos
{
    if((pos.x > koi.position.x) && (pos.y > koi.position.y))
    {
        if((pos.x - koi.position.x) < 100) koi.rotation = 0;
        else
            koi.rotation = 25;
    }
    if((pos.x < koi.position.x) && (pos.y > koi.position.y))
    {
        if ((pos.y - koi.position.y) < 140) koi.rotation = -120;
        else
            koi.rotation = -90;
    }
    if((pos.x > koi.position.x) && (pos.y < koi.position.y))
    {
        if((pos.x - koi.position.x)<100) koi.rotation = 125;
        else
            koi.rotation = 90;
    }
    if((pos.x < koi.position.x) && (pos.y < koi.position.y))
    {
        if((koi.position.x - pos.x) < 100) koi.rotation = 150;
        else
            koi.rotation = 180;
    }
}

-(void) checkKoiLargeRotation:(CCSprite*) koi atPostion:(CGPoint) pos
{
    if((pos.x > koi.position.x) && (pos.y > koi.position.y))
    {
        if((pos.x - koi.position.x) < 100) koi.rotation = -10;
        else
            koi.rotation = 45;
    }
    if((pos.x < koi.position.x) && (pos.y > koi.position.y))
    {
        if ((pos.y - koi.position.y) < 140) koi.rotation = -90;
        else
            koi.rotation = -70;
    }
    if((pos.x > koi.position.x) && (pos.y < koi.position.y))
    {
        if((pos.x - koi.position.x)<100) koi.rotation = 155;
        else
            koi.rotation = 90;
    }
    if((pos.x < koi.position.x) && (pos.y < koi.position.y))
    {
        if((koi.position.x - pos.x) < 100) koi.rotation = 150;
        else
            koi.rotation = 180;
    }
}

-(BOOL) checkKoiDistance:(CCSprite*) koi atPosition:(CGPoint) pos
{
    if (((pos.x - koi.position.x)*(pos.x - koi.position.x) < 900) && ((pos.y - koi.position.y)*(pos.y - koi.position.y) < 900))
    {
        return false;
    }
    else return true;
}
  
-(CCMoveTo*) actionWithDuration:(ccTime)duration pos:(CGPoint) position
{
    CCMoveTo* move_to = [[CCMoveTo alloc] initWithDuration: duration position: position];
    return move_to;
}


-( void )update:( ccTime )dt {
    
    runtime += dt;
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
