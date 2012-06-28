//
//  HelloWorldLayer.h
//  Cocos2DSimpleGame
//
//  Created by Dilip Muthukrishnan on 12-06-15.
//  Copyright PointerWare Innovations Limited 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
// Inserted this code from Ray Wenderlich tutorial.
@interface HelloWorldLayer : CCLayerColor
{
    NSMutableArray *_targets;
    NSMutableArray *_projectiles;
    int _targetsDestroyed;
    CCSprite *_player;
    CCSprite *_nextProjectile;
    int _targetsMissed;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void)addTarget;
-(void)spriteMoveFinished:(id)sender;
-(void)gameLogic:(ccTime)dt;

@end
