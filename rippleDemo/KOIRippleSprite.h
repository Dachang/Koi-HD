//
//  main.m
//  Koi HD
//
//  Created by 大畅 on 13-5-9.
//  Copyright OceanDev 2013. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "cocos2d.h"

// --------------------------------------------------------------------------
// defines default values

#define RIPPLE_DEFAULT_QUAD_COUNT_X             60         
#define RIPPLE_DEFAULT_QUAD_COUNT_Y             40 

#define RIPPLE_BASE_GAIN                        0.1f        // an internal constant

#define RIPPLE_DEFAULT_RADIUS                   500         // radius in pixels  
#define RIPPLE_DEFAULT_RIPPLE_CYCLE             0.25f       // timing on ripple ( 1/frequenzy )
#define RIPPLE_DEFAULT_LIFESPAN                 3.6f        // entire ripple lifespan

#define RIPPLE_BOUNCE                                       // makes ripples bounce off edges
#define RIPPLE_CHILD_MODIFIER                   2.0f        // strength modifier

// --------------------------------------------------------------------------
// typedefs

typedef enum {
    RIPPLE_TYPE_RUBBER,                                     // type1(strange)
    RIPPLE_TYPE_GEL,                                        // type2(better)
    RIPPLE_TYPE_WATER,                                      // type3(water)
} RIPPLE_TYPE;

typedef enum {
    RIPPLE_CHILD_LEFT,
    RIPPLE_CHILD_TOP,
    RIPPLE_CHILD_RIGHT,
    RIPPLE_CHILD_BOTTOM,
    RIPPLE_CHILD_COUNT
} RIPPLE_CHILD;

typedef struct _rippleData {
    bool                    parent;                         // ripple is a parent
    bool                    childCreated[ 4 ];              // child created (4 directions)
    RIPPLE_TYPE             rippleType;                     // type of ripple
    CGPoint                 center;                         // ripple center
    CGPoint                 centerCoordinate;               // ripple center in texture coordinates
    float                   radius;                         // radius at which ripple has faded 100%
    float                   strength;                       // ripple strength 
    float                   runtime;                        // current run time
    float                   currentRadius;                  // current radius
    float                   rippleCycle;                    // ripple cycle timing
    float                   lifespan;                       // total life span       
} rippleData;

// --------------------------------------------------------------------------
// interface

@interface KOIRippleSprite : CCNode {
    CCTexture2D*            m_texture;   
    int                     m_quadCountX;                   // quad count in x and y direction
    int                     m_quadCountY;
    int                     m_VerticesPrStrip;              // number of vertices in a strip
    int                     m_bufferSize;                   // vertice buffer size
    CGPoint*                m_vertice;                      // vertices
    CGPoint*                m_textureCoordinate;            // texture coordinates ( original )
    CGPoint*                m_rippleCoordinate;             // texture coordinates ( ripple corrected )
    bool*                   m_edgeVertice;                  // vertice is a border vertice        
    NSMutableArray*         m_rippleList;                   // list of running ripples
}

// --------------------------------------------------------------------------
// methods

+( KOIRippleSprite* )ripplespriteWithFile:( NSString* )filename;
-( KOIRippleSprite* )initWithFile:( NSString* )filename;
-( void )tesselate;
-( void )addRipple:( CGPoint )pos type:( RIPPLE_TYPE )type strength:( float )strength;
-( void )addRippleChild:( rippleData* )parent type:( RIPPLE_CHILD )type;
-( void )update:( ccTime )dt;

// --------------------------------------------------------------------------

@end