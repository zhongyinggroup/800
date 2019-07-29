//
//  GamePlayScene.h
//  Cow Invaders
//
//  Created by Eric Hodgins on 2019-05-23.
//  Copyright (c) 2019 Eric Hodgins. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GamePlayScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, weak) UITouch *farmerTouch;
@property (nonatomic) NSTimeInterval lastUpdateTime;

@end
