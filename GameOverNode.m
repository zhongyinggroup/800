//
//  GameOverNode.m
//  Cow Invaders
//
//  Created by Eric Hodgins on 2019-06-11.
//  Copyright (c) 2019 Eric Hodgins. All rights reserved.
//

#import "GameOverNode.h"

@implementation GameOverNode

+(instancetype)gameOverAtPosition:(CGPoint)position {
    GameOverNode *gameOver = [self node];
    
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
    gameOverLabel.name = @"GameOver";
    gameOverLabel.text = @"Game Over";
    gameOverLabel.fontSize = 60;
    gameOverLabel.position = position;
    [gameOver addChild:gameOverLabel];
    
    return gameOver;
}

@end
