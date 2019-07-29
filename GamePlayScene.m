//
//  GamePlayScene.m
//  Cow Invaders
//
//  Created by Eric Hodgins on 2019-05-23.
//  Copyright (c) 2019 Eric Hodgins. All rights reserved.
//

// +++++++++ NOTES  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Gesture Recognizers make a small delay with touch events.  look out for touchesBegan when done.
// Physics bodies touching when scene starts do not trigger a contact conditional
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#import "GamePlayScene.h"
#import "AlienNode.h"
#import "Farmer.h"
#import "ProjectileNode.h"
#import "GroundNode.h"
#import "Util.h"
#import "CowNode.h"
#import "BeamNode.h"
#import "AlienWithBeamNode.h"
#import "HudNode.h"
#import "TitleScene.h"
#import "Asteroid.h"
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>

@interface GamePlayScene ()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval timeSinceEnemyAdded;
@property (nonatomic) NSTimeInterval timeSinceFarmerShot;
@property (nonatomic) NSTimeInterval timeSinceAlienWithBeamAdded;

@property (nonatomic, strong) CowNode *cow1;
@property (nonatomic, strong) CowNode *cow2;
@property (nonatomic, strong) CowNode *cow3;
@property (nonatomic, strong) NSMutableArray *cowsArray;

@property (nonatomic, strong) AVAudioPlayer *laserBeamSFX;
@property (nonatomic, strong) AVAudioPlayer *cowSoundSFX;
@property (nonatomic, strong) AVAudioPlayer *farmerExplosionSFX;
@property (nonatomic, strong) AVAudioPlayer *backgroundNoiseSFX;

@property (nonatomic, strong) SKAction *gunshotSound;
@property (nonatomic, strong) SKAction *alienExplosion;

@end


@implementation GamePlayScene {
    float frameWidth;
}

-(void)didMoveToView:(SKView *)view {
//    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapsResponder:)];
//    doubleTapRecognizer.numberOfTapsRequired = 2;
//    doubleTapRecognizer.numberOfTouchesRequired = 1;
//    
//    [self.scene.view addGestureRecognizer:doubleTapRecognizer];
//    
}

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.timeSinceEnemyAdded = 0;
        self.lastUpdateTimeInterval = 0;
        
        // Setup the scene
        
//        self.backgroundColor = [UIColor colorWithRed:0/255.0f green:19/255.0f blue:75/255.0f alpha:1];
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        background.size = self.size;
        background.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:background];
        
        SKShapeNode *grass = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(self.frame.size.width, 150)];
        grass.position = CGPointMake(self.frame.size.width/2, 75);
        grass.lineWidth = 0;
        grass.fillColor = [UIColor colorWithRed:13/255.0f green:73/255.0f blue:0/255.0f alpha:1];
        [grass setHidden:YES];
        [self addChild:grass];
        
        SKSpriteNode *barn = [SKSpriteNode spriteNodeWithImageNamed:@"Barn"];
        barn.anchorPoint = CGPointMake(0, 0);
        barn.position = CGPointMake(0, 150);
        barn.zPosition = 4;
        [barn setHidden:YES];
        [self addChild:barn];
        
        
        self.cow1 = [CowNode cowAtPosition:CGPointMake(40, 110)];
        self.cow1.zPosition = 5;
        [self addChild:self.cow1];
        
        self.cow2 = [CowNode cowAtPosition:CGPointMake(220, 110)];
        self.cow2.zPosition = 5;
        [self addChild:self.cow2];
        
        self.cow3 = [CowNode cowAtPosition:CGPointMake(100, 110)];
        self.cow3.zPosition = 5;
        [self addChild:self.cow3];
        
        self.cowsArray = [NSMutableArray arrayWithArray:@[self.cow1, self.cow2, self.cow3]];
  
        SKSpriteNode *house = [SKSpriteNode spriteNodeWithImageNamed:@"House"];
        house.anchorPoint = CGPointMake(1, 0);
        house.position = CGPointMake(self.frame.size.width, 148);
        house.zPosition = 4;
        [house setHidden:YES];
        [self addChild:house];
        
        SKSpriteNode *fence = [SKSpriteNode spriteNodeWithImageNamed:@"Fence"];
        fence.anchorPoint = CGPointMake(0, 0);
        fence.position = CGPointMake(75, 145);
        fence.zPosition = 4;
        [fence setHidden:YES];
        [self addChild:fence];
        
        SKSpriteNode *moon = [SKSpriteNode spriteNodeWithImageNamed:@"Moon"];
        moon.anchorPoint = CGPointMake(0, 0);
        moon.position = CGPointMake(self.frame.size.width - 50, self.frame.size.height - 70);
        moon.zPosition = 4;
        [self addChild:moon];
        
        
        for (int i = 0; i < 30; i++) {
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
            star.anchorPoint = CGPointMake(0, 0);
            CGFloat x = [Util randomWithMin:5 max:self.frame.size.width];
            CGFloat y = [Util randomWithMin:150 max:self.frame.size.height];
            star.position = CGPointMake(x, y);
            CGFloat scaleAmount = [Util randomWithFloatMin:0.1 max:0.5];
            star.xScale = scaleAmount;
            star.yScale = scaleAmount;
            [self addChild:star];
        }

        
        Farmer *farmer = [Farmer farmerAtPosition:CGPointMake(10, 60)];
        [self addChild: farmer];
        
        frameWidth = self.frame.size.width;
        
        // PHYSICS WORLD SETUP
        self.physicsWorld.gravity = CGVectorMake(0, -3);
        self.physicsWorld.contactDelegate = self;
        
        GroundNode *ground = [GroundNode groundWithSize:CGSizeMake(frameWidth + 100, 22)];
        [self addChild:ground];
        
        
        //ADD THE HUD
        HudNode *hud = [HudNode hudAtPosition:CGPointMake(frameWidth/2+50, self.frame.size.height - 10)];
        [self addChild:hud];
        
        
        [self setupSounds];
        
        
    }
    
    return self;
}

-(void)setupSounds {
    NSURL *urlBeam = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"LaserBeam" ofType:@"caf"]];
    self.laserBeamSFX = [[AVAudioPlayer alloc] initWithContentsOfURL:urlBeam error:nil];
    self.laserBeamSFX.volume = 0.1;
    self.laserBeamSFX.numberOfLoops = -1;
    
    NSURL *urlCow = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CowSound" ofType:@"caf"]];
    self.cowSoundSFX = [[AVAudioPlayer alloc] initWithContentsOfURL:urlCow error:nil];
    
    NSURL *urlFarmerExplosionSFX = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"FarmerExplosionSFX" ofType:@"caf"]];
    self.farmerExplosionSFX = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFarmerExplosionSFX error:nil];
    
    self.gunshotSound = [SKAction playSoundFileNamed:@"GunshotSFX.caf" waitForCompletion:NO];
    self.alienExplosion = [SKAction playSoundFileNamed:@"AlienShipExplosion.caf" waitForCompletion:NO];
    
    NSURL *urlBackgroundNoiseSFX = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BackgroundNoise" ofType:@"caf"]];
    self.backgroundNoiseSFX = [[AVAudioPlayer alloc] initWithContentsOfURL:urlBackgroundNoiseSFX error:nil];
    [self.backgroundNoiseSFX play];
}

//-(void)tapsResponder: (UITapGestureRecognizer *)sender {
//    if (sender.numberOfTapsRequired == 2) {
//        NSLog(@"Position: (%f, %f)", [sender locationInView:self.view].x, [sender locationInView:self.view].y);
//    }
//}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.farmerTouch = [touches anyObject];
    
    for (UITouch *touch in touches) {
        CGPoint position = [touch locationInNode:self];
        if (position.y >= 80) {
            [self shootProjectileTowardsPosition: position];
            break;
        }
    }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}


#pragma mark - Update method

-(void)update:(NSTimeInterval)currentTime {
    

    if (self.lastUpdateTime == 0) {
        self.lastUpdateTime = currentTime;
    }
    
    NSTimeInterval timeDelta = currentTime - self.lastUpdateTime;
    
    // making the farmer move
    Farmer *farmer = (Farmer *)[self childNodeWithName:@"Farmer"];
    if (self.farmerTouch && [self.farmerTouch locationInNode:self].y < 80) {
        [farmer farmerRun];
        [self moveFarmerTowardsPosition:[self.farmerTouch locationInNode:self] byTimeDelta:timeDelta];
    } else if (self.farmerTouch && farmer.farmerCanShoot) {
        [farmer farmerRun];
    } else if (!self.farmerTouch) {
        [farmer farmerStandStill];
    }
    
    // Checking if Farmer was boosted off screen
//    if (farmer.position.x < -50 || farmer.position.x > self.frame.size.width + 50 || farmer.position.y < 0) {
//        [self reSpawnFarmer];
//    }
    
    self.lastUpdateTime = currentTime;
    
    // making the aliens spawn
    if (self.lastUpdateTimeInterval) {
        self.timeSinceEnemyAdded += currentTime - self.lastUpdateTimeInterval;
        self.timeSinceFarmerShot += currentTime - self.lastUpdateTimeInterval;
        self.timeSinceAlienWithBeamAdded += currentTime - self.lastUpdateTimeInterval;
    }
    
    if (self.timeSinceEnemyAdded > 2.0) {
        [self addAlien];
        self.timeSinceEnemyAdded = 0;
    }
    
    // making the aliens with beams spawn
    if (self.timeSinceAlienWithBeamAdded > 8.0) {
        [self addAlienWithBeam];
        if ([Util getYesOrNo]) {
            [self.cowSoundSFX play];
        }
        
        // adding asteroid too
        [self addAsteroid];
        
        self.timeSinceAlienWithBeamAdded = 0;
    }
    
    // Increase time between Farmer shots
    if (self.timeSinceFarmerShot > 0.5) {
        farmer.farmerCanShoot = YES;
    } else {
        farmer.farmerCanShoot = NO;
    }
    

    
    self.lastUpdateTimeInterval = currentTime;
    
}

-(void)reSpawnFarmer {
    Farmer *farmer = (Farmer *)[self childNodeWithName:@"Farmer"];
    [farmer removeFromParent];
    
    Farmer *newFarmer = [Farmer farmerAtPosition:CGPointMake(frameWidth/2, self.frame.size.height + 10)];
    [self addChild:newFarmer];
}


-(void)moveFarmerTowardsPosition:(CGPoint)position byTimeDelta:(NSTimeInterval)timeDelta {
    Farmer *farmer = (Farmer *)[self childNodeWithName:@"Farmer"];

    CGFloat distanceLeft = fabs(position.x - farmer.position.x);
    CGFloat distanceToTravel = timeDelta * FarmerSpeed;
    CGFloat xOffset;

    if (position.y < 80) {
        if (farmer.position.x >= position.x && distanceLeft > 4) {
            xOffset = farmer.position.x - distanceToTravel;
            farmer.position = CGPointMake(xOffset, farmer.position.y);
        } else if (farmer.position.x < position.x && distanceLeft > 4) {
            xOffset = farmer.position.x + distanceToTravel;
            farmer.position = CGPointMake(xOffset, farmer.position.y);
        }
    }
    

}


-(void)shootProjectileTowardsPosition:(CGPoint)position {
    Farmer *farmer = (Farmer *)[self childNodeWithName:@"Farmer"];
    if (farmer.farmerCanShoot) {
        //gunshot explosion
        SKEmitterNode *gunShotParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"GunShotParticle" ofType:@"sks"]];
        gunShotParticle.position = CGPointMake(farmer.position.x - 10, farmer.position.y + 30);
        [self addChild:gunShotParticle];
        [gunShotParticle runAction:[SKAction waitForDuration:0.1] completion:^{
            [gunShotParticle removeFromParent];
        }];
        
        
        // gunshot sound
        [self runAction:self.gunshotSound];
        
        self.timeSinceFarmerShot = 0;
        ProjectileNode *projectile = [ProjectileNode projectileAtPosition:CGPointMake(farmer.position.x - 14, farmer.position.y + 26)];
        [projectile moveTowardsPosition:position frameWidth:frameWidth];
        [self addChild:projectile];
    }
    
}


#pragma mark - Contact Methods
-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask == CollisionCategoryEnemy || firstBody.categoryBitMask == CollisionCategoryAlienBeam) && secondBody.categoryBitMask == CollisionCategoryProjectile) {
        // Bullet hitting the alien ships
        // explosion sound
        [self runAction:self.alienExplosion];
        
        AlienNode *alien = (AlienNode *)firstBody.node;
        ProjectileNode *projectile = (ProjectileNode *)secondBody.node;
        HudNode *hud = (HudNode *)[self childNodeWithName:@"HUD"];
        [alien removeFromParent];
        [projectile removeFromParent];
        [hud increaseScore];
        
        [self createDebrisAtPosition:contact.contactPoint];
        [self.laserBeamSFX stop];
        
    } else if (firstBody.categoryBitMask == CollisionCategoryEnemy && secondBody.categoryBitMask == CollisionCategoryFarmer) {
        //Alien ship hitting the farmer
        [self.farmerExplosionSFX play];
        SKEmitterNode *farmerExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"FarmerExplosionParticle" ofType:@"sks"]];
        farmerExplosion.position = contact.contactPoint;
        farmerExplosion.zPosition = 10;
        [self addChild:farmerExplosion];
        
        AlienNode *alien = (AlienNode *)firstBody.node;
        Farmer *farmer = (Farmer *)secondBody.node;
        [self createDebrisAtPosition:contact.contactPoint];
        [alien removeFromParent];
        [farmer removeFromParent];
        
        [self checkScore];
        [self transitionEndingGameOverScene];
        
    } else if (firstBody.categoryBitMask == CollisionCategoryCow && secondBody.categoryBitMask == CollisionCategoryBeam) {
        // Beam Hitting the cow
        HudNode *hud = (HudNode *)[self childNodeWithName:@"HUD"];
        
        AlienWithBeamNode *alienWithBeam = (AlienWithBeamNode *)[self childNodeWithName:@"AlienWithBeam"];
        alienWithBeam.physicsBody.contactTestBitMask = 0;
        [self.cowsArray removeObjectAtIndex:0];
        
        CowNode *cow = (CowNode *)firstBody.node;
        cow.physicsBody.contactTestBitMask = 0;
        [cow setupAnimation];
        
        SKAction *cowMove = [cow moveCowTowardsAlien:alienWithBeam.position];
        [cow runAction:cowMove completion:^{
            [cow removeFromParent];
            [alienWithBeam removeBeam];
            SKAction *moveAlien = [alienWithBeam moveAlienOffScreen:CGPointMake(self->frameWidth + 40, 400) stopLaserSound:self.laserBeamSFX];
            [alienWithBeam runAction:moveAlien completion:^{
                [alienWithBeam removeFromParent];
                if ([hud loseLife]) {
                    [self checkScore];
                    TitleScene *titleScene = [TitleScene sceneWithSize:self.frame.size];
                    [self.view presentScene:titleScene transition:[SKTransition fadeWithDuration:3.0]];
                }

            }];
        }];
        
    } else if (firstBody.categoryBitMask == CollisionCategoryFarmer && secondBody.categoryBitMask == CollisionCategoryAsteroid) {
        // Asteroid hitting farmer
        [self.farmerExplosionSFX play];
        SKEmitterNode *farmerExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"FarmerExplosionParticle" ofType:@"sks"]];
        farmerExplosion.position = contact.contactPoint;
        farmerExplosion.zPosition = 15;
        [self addChild:farmerExplosion];
        
        Farmer *farmer = (Farmer *)firstBody.node;
        [farmer removeFromParent];
        
        [self checkScore];
        [self transitionEndingGameOverScene];
    }
}

//Transition scene when asteroid hits farmer or when alienship hits a farmer
-(void)transitionEndingGameOverScene {
    SKAction *delayScene = [SKAction waitForDuration:2.0];
    [self runAction:delayScene completion:^{
        TitleScene *titleScene = [TitleScene sceneWithSize:self.frame.size];
        SKTransition *fadeOut = [SKTransition fadeWithDuration:2.0];
        fadeOut.pausesOutgoingScene = NO;
        [self.laserBeamSFX stop];
        [self.view presentScene:titleScene transition:fadeOut];
    }];
}

-(void)setupCowHitByBeam:(CowNode *)cow position:(CGPoint)position {
    [cow setupAnimation];
    [cow moveCowTowardsAlien:position];
}

-(void)createDebrisAtPosition:(CGPoint)position {
    NSInteger numberOfPieces = [Util randomWithMin:4 max:8];
    
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"ExplosionParticle" ofType:@"sks"]];
    explosion.position = position;
    explosion.zPosition = 10;
    [self addChild:explosion];
    [explosion runAction:[SKAction waitForDuration:0.2] completion:^{
        [explosion removeFromParent];
    }];

    for (int i=0; i < numberOfPieces; i++) {
        NSInteger randomPiece = [Util randomWithMin:1 max:5];
        NSString *imageName = [NSString stringWithFormat:@"Debris_%ld", (long)randomPiece];
        
        
        SKSpriteNode *debris = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        debris.position = position;
        debris.zPosition = 10;
        [self addChild:debris];
        
        debris.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:debris.frame.size];
        debris.physicsBody.categoryBitMask = CollisionCategoryDebris;
        debris.physicsBody.contactTestBitMask = 0;
        debris.physicsBody.collisionBitMask = CollisionCategoryGround | CollisionCategoryDebris;
        debris.name = @"Debris";
        
        debris.physicsBody.velocity = CGVectorMake([Util randomWithMin:-350 max:350], [Util randomWithMin:350 max:550]);
        [debris runAction:[SKAction waitForDuration:2.5] completion:^{
            [debris removeFromParent];
        }];
    }
}

-(void)addAlien {
    float y = self.frame.size.height + 50;
    float x = [Util randomWithMin:30 max:self.frame.size.width - 30];
    AlienNode *alien = [AlienNode alienAtPosition:CGPointMake(x, y)];
    [self addChild:alien];
}

-(void)addAsteroid {
    float y = self.frame.size.height + 50;
    float x = [Util randomWithMin:30 max:self.frame.size.width - 30];
    Asteroid *asteroid = [Asteroid asteroidAtPosition:CGPointMake(x, y)];
    [self addChild:asteroid];
}

-(void)addAlienWithBeam {
    float randomHeight = [Util randomWithMin:100 max:600];
    AlienWithBeamNode *alienWithBeam = [AlienWithBeamNode alienWithBeamAtPosition:CGPointMake(frameWidth + 20, randomHeight)];
    alienWithBeam.zPosition = 10;
    [self addChild:alienWithBeam];
    
    CowNode *cow = self.cowsArray[0];
    [alienWithBeam moveTowardsCowAtPosition:CGPointMake(cow.position.x, 110) withBeamSound:self.laserBeamSFX];

}

#pragma mark - Save score

-(void)checkScore {
    HudNode *hud = (HudNode *)[self childNodeWithName:@"HUD"];
    NSInteger presentScore = hud.score;
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
    if (presentScore > highScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:hud.score forKey:@"high_score"];
        
        [self submitScore];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:hud.score forKey:@"last_score"];
}

- (void) submitScore {
    if (![GKLocalPlayer localPlayer].authenticated) return;
    
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.DEFEND3COWS"];
    score.value = [[NSUserDefaults standardUserDefaults] integerForKey:@"high_score"];
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {}];
}

@end
