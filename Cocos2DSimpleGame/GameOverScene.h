//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Dilip Muthukrishnan on 12-06-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// These class declarations were inserted from Ray Wenderlich tutorial.

@interface GameOverLayer : CCLayerColor
{
    CCLabelTTF *_label;
}

@property (nonatomic, retain) CCLabelTTF *label;

@end


@interface GameOverScene : CCScene
{
    GameOverLayer *_layer;
}

@property (nonatomic, retain) GameOverLayer *layer;

@end