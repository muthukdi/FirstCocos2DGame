//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by Dilip Muthukrishnan on 12-06-15.
//  Copyright PointerWare Innovations Limited 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
// Inserted this code from Ray Wenderlich tutorial.
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "Monster.h"

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

// Inserted this code from Ray Wenderlich tutorial.
-(void)gameLogic:(ccTime)dt {
    [self addTarget];
}

// Inserted this code from Ray Wenderlich tutorial.
-(void)spriteMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    if (sprite.tag == 1) { // target
        [_targets removeObject:sprite];
        _targetsMissed++;
        if (_targetsMissed > 3)
        {
            GameOverScene *gameOverScene = [GameOverScene node];
            [gameOverScene.layer.label setString:@"You Lose :["];
            [[CCDirector sharedDirector] replaceScene:gameOverScene]; 
        }
    } else if (sprite.tag == 2) { // projectile
        [_projectiles removeObject:sprite];
    }
    [self removeChild:sprite cleanup:YES];
}

// Inserted this code from Ray Wenderlich tutorial.
-(void)addTarget {
    
    // Create the target
    Monster *target = nil;
    if ((arc4random() % 2) == 0) {
        target = [WeakAndFastMonster monster];
    } else {
        target = [StrongAndSlowMonster monster];
    }
    
    // Determine where to spawn the target along the Y axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = target.contentSize.height/2;
    int maxY = winSize.height - target.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the target slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
    [self addChild:target];
    
    // Store target in array and give it a tag
    target.tag = 1;
    [_targets addObject:target];
    
    // Determine speed of the target
    int minDuration = target.minMoveDuration; //2.0;
    int maxDuration = target.maxMoveDuration; //4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration 
                                        position:ccp(-target.contentSize.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self 
                                             selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
}

// Inserted this code from Ray Wenderlich tutorial.
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_nextProjectile != nil) return;
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _nextProjectile = [[CCSprite spriteWithFile:@"Projectile2.jpg"] retain];
    _nextProjectile.position = ccp(20, winSize.height/2);
    
    // Determine offset of location to projectile
    int offX = location.x - _nextProjectile.position.x;
    int offY = location.y - _nextProjectile.position.y;
    
    // Bail out if we are shooting down or backwards
    if (offX <= 0) return;
    
    // Determine where we wish to shoot the projectile to
    int realX = winSize.width + (_nextProjectile.contentSize.width/2);
    float ratio = (float) offY / (float) offX;
    int realY = (realX * ratio) + _nextProjectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far we're shooting
    int offRealX = realX - _nextProjectile.position.x;
    int offRealY = realY - _nextProjectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 280/1; // 280pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Determine angle for player to face
    float angleRadians = atanf((float)offRealY / (float)offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    float rotateSpeed = 0.5 / M_PI; // Would take 0.5 seconds to rotate 0.5 radians, or half a circle
    float rotateDuration = fabs(angleRadians * rotateSpeed);    
    [_player runAction:[CCSequence actions:
                        [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                        [CCCallFunc actionWithTarget:self selector:@selector(finishShoot)],
                        nil]];
    
    // Move projectile to actual endpoint
    [_nextProjectile runAction:[CCSequence actions:
                                [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                                [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                                nil]];
    
    // Add to projectiles array
    _nextProjectile.tag = 2;
}

// Inserted this code from Ray Wenderlich tutorial.
- (void)finishShoot {
    
    // Ok to add now - we've finished rotation!
    [self addChild:_nextProjectile];
    [_projectiles addObject:_nextProjectile];
    
    // Play shooting sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:@"firing.wav"];
    
    // Release
    [_nextProjectile release];
    _nextProjectile = nil;
    
}

// Inserted this code from Ray Wenderlich tutorial.
// Checking ALL the targets and ALL the projectiles repeatedly seems kind of inefficient -Dilip
- (void)update:(ccTime)dt {
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        CGRect projectileRect = CGRectMake(
                                           projectile.position.x - (projectile.contentSize.width/2), 
                                           projectile.position.y - (projectile.contentSize.height/2), 
                                           projectile.contentSize.width, 
                                           projectile.contentSize.height);
        
        BOOL monsterHit = FALSE;
        NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *target in _targets) {
            Monster *monster = (Monster *)target;
            CGRect targetRect = CGRectMake(
                                           target.position.x - (target.contentSize.width/2), 
                                           target.position.y - (target.contentSize.height/2), 
                                           target.contentSize.width, 
                                           target.contentSize.height);
            
            if (CGRectIntersectsRect(projectileRect, targetRect)) {
                monsterHit = TRUE;
                monster.hp--;
                if (monster.hp <= 0) {
                    [targetsToDelete addObject:target];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.wav"];
                }
                else {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.caf"];
                }
                break;			
            }						
        }
        
        for (CCSprite *target in targetsToDelete) {
            [_targets removeObject:target];
            [self removeChild:target cleanup:YES];
            _targetsDestroyed++;
            if (_targetsDestroyed > 10) {
                GameOverScene *gameOverScene = [GameOverScene node];
                _targetsDestroyed = 0;
                [gameOverScene.layer.label setString:@"You Win!"];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        
        if (monsterHit) {
            [projectilesToDelete addObject:projectile];
        }
        [targetsToDelete release];
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}

// Inserted this code from Ray Wenderlich tutorial.
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _player = [[CCSprite spriteWithFile:@"Player2.jpg"] retain];
        _player.position = ccp(_player.contentSize.width/2, winSize.height/2);
        [self addChild:_player];
        [self reorderChild:_player z:1];
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];
        self.isTouchEnabled = YES;
        _targets = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        
        // Play background music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"music.caf"];
    }
    return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
    [_targets release];
    _targets = nil;
    [_projectiles release];
    _projectiles = nil;
    [_player release];
    _player = nil;
    
	// cocos2d will automatically release all the children
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
