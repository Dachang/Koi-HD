//
//  main.m
//  Koi HD
//
//  Created by 大畅 on 13-5-9.
//  Copyright OceanDev 2013. All rights reserved.
//



#import "KOIRippleSprite.h"



@implementation KOIRippleSprite


// --------------------------------methods----------------------------------//


+( KOIRippleSprite* )ripplespriteWithFile:( NSString* )filename {
	return [ [ [ self alloc ] initWithFile:filename ] autorelease ];
}

// -------------------------init texture file-------------------------------//

-( KOIRippleSprite* )initWithFile:( NSString* )filename {
    self = [ super init ];
    // load texture
    m_texture = [ [ CCTextureCache sharedTextureCache ] addImage: filename ];
    // reset internal data
    m_vertice = nil;
    m_textureCoordinate = nil;
    // builds the vertice and texture-coordinates arrays
    m_quadCountX = RIPPLE_DEFAULT_QUAD_COUNT_X;
    m_quadCountY = RIPPLE_DEFAULT_QUAD_COUNT_Y;
    [ self tesselate ];
    
    // create ripple list
    m_rippleList = [ [ [ NSMutableArray alloc ] init ] retain ];
    
    return( self );
}

// ------------------------------set GLView------------------------------//

-( void )draw {
    if ( self.visible == NO ) return;
    
    glPushMatrix( );
    
    glDisableClientState( GL_COLOR_ARRAY );

    glBindTexture( GL_TEXTURE_2D, [ m_texture name ] ); 
    
    // set texture coordinates
    // if no ripples running, use original coordinates
    glTexCoordPointer( 2, GL_FLOAT, 0, ( m_rippleList.count == 0 ) ? m_textureCoordinate : m_rippleCoordinate );
    
    // set vertice pointer
    glVertexPointer( 2, GL_FLOAT, 0, m_vertice );
    
    // draw as many triangle fans, as quads in y direction
    for ( int strip = 0; strip < m_quadCountY; strip ++ ) {
        glDrawArrays( GL_TRIANGLE_STRIP, strip * m_VerticesPrStrip, m_VerticesPrStrip );
    }
    
    glEnableClientState( GL_COLOR_ARRAY );
    
    glPopMatrix( );
}

// ------------------------------dealloc--------------------------------//

-( void )dealloc {
    rippleData* runningRipple;
    
    // clean up buffers
    free( m_vertice );
    free( m_textureCoordinate );
    free( m_rippleCoordinate );
    free( m_edgeVertice );
    
    // clean up running ripples
    for ( int count = 0; count < m_rippleList.count; count ++ ) {
        
        // get a pointer and free manually, as data was allocated manually
        // a void pointer would do, but this adds readability at no expense
        runningRipple = ( rippleData* )[ [ m_rippleList objectAtIndex:count ] pointerValue ];
        free( runningRipple );
        
    }
    
    // delete list
    [ m_rippleList release ];
    
    // done
    [ super dealloc ];
}

// ---------------------------tesslation(bounce edge)------------------------------//

-( void )tesselate {
    int vertexPos = 0;
    CGPoint normalized;
    
    // clear buffers
    free( m_vertice );
    free( m_textureCoordinate );
    free( m_rippleCoordinate );
    free( m_edgeVertice );
    
    // calculate vertices pr strip
    m_VerticesPrStrip = 2 * ( m_quadCountX + 1 );
    
    // calculate buffer size
    m_bufferSize = m_VerticesPrStrip * m_quadCountY;
    
    // allocate buffers
    m_vertice = malloc( m_bufferSize * sizeof( CGPoint ) );
    m_textureCoordinate = malloc( m_bufferSize * sizeof( CGPoint ) );
    m_rippleCoordinate = malloc( m_bufferSize * sizeof( CGPoint ) );
    m_edgeVertice = malloc( m_bufferSize * sizeof( bool ) );
    
    // reset vertice pointer
    vertexPos = 0;
    
    // create all vertices and default texture coordinates
    for ( int y = 0; y < m_quadCountY; y ++ ) {
        
        // x counts to quadcount + 1, because number of vertices is number of quads + 1
        for ( int x = 0; x < ( m_quadCountX + 1 ); x ++ ) {
        
            // for each x vertex, an upper and lower y position is calculated, to create the triangle strip
            for ( int yy = 0; yy < 2; yy ++ ) {
                
                // first simply calculate a normalized position into rectangle
                normalized.x = ( float )x / ( float )m_quadCountX;
                normalized.y = ( float )( y + yy ) / ( float )m_quadCountY;
                
                // calculate vertex by multiplying rectangle ( texture ) size
                m_vertice[ vertexPos ] = ccp( normalized.x * [ m_texture contentSize ].width, normalized.y * [ m_texture contentSize ].height );
                
                // adjust texture coordinates according to texture size
                m_textureCoordinate[ vertexPos ] = ccp( normalized.x * m_texture.maxS, m_texture.maxT - ( normalized.y * m_texture.maxT ) );
                
                // check if vertice is an edge vertice
                m_edgeVertice[ vertexPos ] = ( 
                                              ( x == 0 ) || 
                                              (x == m_quadCountX) || (x == m_quadCountX - 1) ||
                                              ( ( y == 0 ) && ( yy == 0 ) ) || 
                                              ( ( y == ( m_quadCountY - 1 ) )) || (( y == ( m_quadCountY - 2 )) && ( yy > 0 )) || (( y == ( m_quadCountY - 3 )) && ( yy > 0 )));
                
                // next buffer pos
                vertexPos ++;
                
            }
        } 
    } 
}

// ---------------add ripples into running ripple list--------------------------------//

-( void )addRipple:( CGPoint )pos type:( RIPPLE_TYPE )type strength:( float )strength {
    rippleData* newRipple;
    
    // allocate new ripple
    newRipple = malloc( sizeof( rippleData ) );
    
    // initialize ripple
    newRipple->parent = YES;
    for ( int count = 0; count < 4; count ++ ) newRipple->childCreated[ count ] = NO;
    newRipple->rippleType = type;
    newRipple->center = pos;
    newRipple->centerCoordinate = ccp( pos.x / [ m_texture contentSize ].width * m_texture.maxS, m_texture.maxT - ( pos.y / [ m_texture contentSize ].height * m_texture.maxT ) );
    newRipple->radius = RIPPLE_DEFAULT_RADIUS; // * strength;
    newRipple->strength = strength; 
    newRipple->runtime = 0;
    newRipple->currentRadius = 0;
    newRipple->rippleCycle = RIPPLE_DEFAULT_RIPPLE_CYCLE;
    newRipple->lifespan = RIPPLE_DEFAULT_LIFESPAN;
    
    // add ripple to running list 
	[ m_rippleList addObject:[ NSValue valueWithPointer:newRipple ] ];


}

// ---------------adds a ripple child, to mimic bouncing ripples-----------------//


-( void )addRippleChild:( rippleData* )parent type:( RIPPLE_CHILD )type {
    rippleData* newRipple;
    CGPoint pos;

    // allocate new ripple
    newRipple = malloc( sizeof( rippleData ) );
    
    // new ripple is a copy of its parent (almost)
    memcpy( newRipple, parent, sizeof( rippleData ) );
    
    // not a parent
    newRipple->parent = NO;
    
    // mirror position
    switch ( type ) {
        case RIPPLE_CHILD_LEFT:
            pos = ccp( -parent->center.x, parent->center.y );
            break;
        case RIPPLE_CHILD_TOP:
            pos = ccp( parent->center.x, 1024 + ( 1024 - parent->center.y ) );
            break;
        case RIPPLE_CHILD_RIGHT:
            pos = ccp( 768 + ( 768 - parent->center.x ), parent->center.y );
            break;
        case RIPPLE_CHILD_BOTTOM:
        default:
            pos = ccp( parent->center.x, -parent->center.y );            
            break;
    }
    
    newRipple->center = pos;
    newRipple->centerCoordinate = ccp( pos.x / [ m_texture contentSize ].width * m_texture.maxS, m_texture.maxT - ( pos.y / [ m_texture contentSize ].height * m_texture.maxT ) );
    newRipple->strength *= RIPPLE_CHILD_MODIFIER;
    
    // indicate child used
    parent->childCreated[ type ] = YES;        
            
    // add ripple to running list 
	[ m_rippleList addObject:[ NSValue valueWithPointer:newRipple ] ];
}

// --------------update: called every frame, manipulate textures--------------------//

-( void )update:( ccTime )dt {
    rippleData* ripple;
    CGPoint pos;
    float distance, correction;
    
    // test if any ripples exist
    if ( m_rippleList.count == 0 ) return;
    
    // ripples are simulated by altering texture coordinates
    // on all updates, an entire new array is calculated from the base array 
    
    memcpy( m_rippleCoordinate, m_textureCoordinate, m_bufferSize * sizeof( CGPoint ) );
    
    // scan through running ripples
    // the scan is backwards
    for ( int count = ( m_rippleList.count - 1 ); count >= 0; count -- ) {
    
        // get ripple data
        ripple = ( rippleData* )[ [ m_rippleList objectAtIndex:count ] pointerValue ];
        
        // scan through all texture coordinates
        for ( int count = 0; count < m_bufferSize; count ++ ) {
            
            // dont modify edge vertices
            if ( m_edgeVertice[ count ] == NO ) {
                
                // calculate distance
                distance = ccpDistance( ripple->center, m_vertice[ count ] );
                
                // only modify vertices within range
                if ( distance <= ripple->currentRadius ) {
                
                    // load the texture coordinate into an easy to use var
                    pos = m_rippleCoordinate[ count ];  
            
                    // calculate a ripple correction
                    switch ( ripple->rippleType ) {
                        
                        case RIPPLE_TYPE_RUBBER:
                            // method A
                            // calculate a sinus, based only on time
                            correction = sinf( 2 * M_PI * ripple->runtime / ripple->rippleCycle );
                            break;
                            
                        case RIPPLE_TYPE_GEL:
                            // method B
                            // calculate a sinus, based both on time and distance
                            // this will look more better, since sinus will travel with radius                            
                            correction = sinf( 2 * M_PI * ( ripple->currentRadius - distance ) / ripple->radius * ripple->lifespan / ripple->rippleCycle );
                            break;
                            
                        case RIPPLE_TYPE_WATER:
                        default:
                            // method C
                            // like method b, but faded for time and distance to center
                            // this will look more like water     
                            correction = ( ripple->radius * ripple->rippleCycle / ripple->lifespan ) / ( ripple->currentRadius - distance );
                            if ( correction > 1.0f ) correction = 1.0f;
                            

                            correction *= correction;
                            
                            correction *= sinf( 2 * M_PI * ( ripple->currentRadius - distance ) / ripple->radius * ripple->lifespan / ripple->rippleCycle );
                            break;
                            
                    }
                                                                    
                    // distance Calibration
                    correction *= 1 - ( distance / ripple->currentRadius );
                    
                    // time Calibration
                    correction *= 1 - ( ripple->runtime / ripple->lifespan );
                    
                    // adjust for base gain and user strength
                    correction *= RIPPLE_BASE_GAIN;
                    correction *= ripple->strength;
                    
                    // finally modify the coordinate by interpolating
                    correction /= ccpDistance( ripple->centerCoordinate, pos );
                    pos = ccpAdd( pos, ccpMult( ccpSub( pos, ripple->centerCoordinate ), correction ) );
                    
                    // clamp texture coordinates to avoid artifacts
                    pos = ccpClamp( pos, CGPointZero, ccp( m_texture.maxS, m_texture.maxT ) );
                 
                    // save modified coordinate
                    m_rippleCoordinate[ count ] = pos;
                
                }
            }
        }
        
        // calculate radius
        ripple->currentRadius = ripple->radius * ripple->runtime / ripple->lifespan;
        
        // check if ripple should expire
        ripple->runtime += dt;
        if ( ripple->runtime >= ripple->lifespan ) {
            
            // free memory, and remove from list
            free( ripple );
            [ m_rippleList removeObjectAtIndex:count ];
            
        } else {
            
#ifdef RIPPLE_BOUNCE
            // check for creation of child ripples (bounce)
            if ( ripple->parent == YES ) {
                
                // left ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_LEFT ] == NO ) && ( ripple->currentRadius > ripple->center.x ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_LEFT ];
                } 
            
                // top ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_TOP ] == NO ) && ( ripple->currentRadius > 320 - ripple->center.y ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_TOP ];
                }
            
                // right ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_RIGHT ] == NO ) && ( ripple->currentRadius > 480 - ripple->center.x ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_RIGHT ];
                }
                
                // bottom ripple
                if ( ( ripple->childCreated[ RIPPLE_CHILD_BOTTOM ] == NO ) && ( ripple->currentRadius > ripple->center.y ) ) {
                    [ self addRippleChild:ripple type:RIPPLE_CHILD_BOTTOM ];
                } 
               
            
            
            }
#endif
            
        }
    
    }
}


@end
