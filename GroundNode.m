//
//  GroundNode.m
//  Cow Invaders
//
//  Created by Eric Hodgins on 2019-05-27.
//  Copyright (c) 2019 Eric Hodgins. All rights reserved.
//

#import "GroundNode.h"
#import "Util.h"

@implementation GroundNode

+(instancetype)groundWithSize:(CGSize)size {
    GroundNode *ground = [self spriteNodeWithColor:[SKColor clearColor] size:size];
    ground.name = @"Ground";
    ground.position = CGPointMake(size.width / 2, size.height / 2);
    ground.zPosition = 1;
    [ground setupPhysicsBody];

    return ground;
}

- (void) setupPhysicsBody {
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.dynamic = NO;
    self.physicsBody.categoryBitMask = CollisionCategoryGround;
    self.physicsBody.collisionBitMask = CollisionCategoryDebris;
    self.physicsBody.contactTestBitMask = CollisionCategoryEnemy;
}
@end
