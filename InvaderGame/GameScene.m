//
//  GameScene.m
//  InvaderGame
//
//  Created by shima jinsei on 2014/10/23.
//  Copyright (c) 2014年 Jinsei Shima. All rights reserved.
//

#import "GameScene.h"
#import "TitleScene.h"
#import <FlatUIKit.h>

enum
{
    kDragNone,  //初期値
    kDragStart, //Drag開始
    kDragEnd,   //Drag終了
};
enum {
    kMoveRight = 0,
    kMoveLeft ,
};

#define kEnemyCategoryMask  0x1<<0
#define kPlayerCategoryMask 0x1<<1
#define kWallCategoryMask   0x1<<1 | 0x1<<0
#define kEnemyMask 0x1<<2

//ミサイル
#define kPlayerContactMask  0x1<<0
#define kEnemyContactMask   0x1<<1


@implementation GameScene
{
    CFTimeInterval lastMoveTime;
    CFTimeInterval lastAttackTime;
    int status;
    int playerstatus;
    NSMutableArray *attackEnemyList;
    SKShapeNode *tri;
    SKShapeNode *tri_shadow;
    //SKSpriteNode *sprite;
    
    SKSpriteNode *myball;
    SKSpriteNode *settingButton;
    SKSpriteNode *shotButton;
    SKSpriteNode *rightButton;
    SKSpriteNode *leftButton;
    
    
    int count_enemy;
    int set_count;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        attackEnemyList = [[NSMutableArray alloc] init];
        [self setBack];
        //壁の作成
        for(int i=0;i<4;i++) {
            [self setUpWall:30 + i*90];
        }
        
        [self setUpPlayer];
        [self setUpEnemy];
        [self setButton];
        
        self.physicsWorld.contactDelegate = self;
        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    playerstatus = kDragNone;
    
    //設定ボタン
    CGPoint point = [[touches anyObject] locationInNode:self];
    if (settingButton != nil && [settingButton containsPoint:point] && set_count==0) {
        SKTexture *textures = [SKTexture textureWithImageNamed:@"playButton2"];
        settingButton = [[SKSpriteNode alloc] initWithTexture:textures];
        settingButton.size = CGSizeMake(textures.size.width, textures.size.height);
        settingButton.name = @"settingButton";
        settingButton.xScale = 0.4;
        settingButton.yScale = 0.4;
        settingButton.position = CGPointMake(self.size.width*0.9, self.size.height*0.92);
        [self addChild:settingButton];
        set_count = 1;
        self.paused = YES;
    }else if(settingButton != nil && [settingButton containsPoint:point] &&set_count == 1){
        self.paused = NO;
        SKTexture *textures = [SKTexture textureWithImageNamed:@"stopButton2"];
        settingButton = [[SKSpriteNode alloc] initWithTexture:textures];
        settingButton.size = CGSizeMake(textures.size.width, textures.size.height);
        settingButton.name = @"settingButton";
        settingButton.xScale = 0.4;
        settingButton.yScale = 0.4;
        settingButton.position = CGPointMake(self.size.width*0.9, self.size.height*0.92);
        [self addChild:settingButton];
        set_count = 0;
    }
    
    //shotButtonをおした時の処理
    if (shotButton != nil && [shotButton containsPoint:point]) {
        if(playerstatus ==! kDragStart){
            [self attack:CGPointMake(tri.position.x, tri.position.y + 10)
                 bitMask:kPlayerContactMask
             moveToPoint:CGPointMake(tri.position.x,  tri.position.y + 10 + self.frame.size.height)
             attackColor:[SKColor blueColor]
             ];
            playerstatus = kDragNone;
        }
    }
    //rightButtonをおした時の処理
    if (rightButton != nil && [rightButton containsPoint:point]) {
        if(tri.position.x < self.frame.size.width){
            tri.position = CGPointMake(tri.position.x+10, tri.position.y);
            tri_shadow.position = CGPointMake(tri_shadow.position.x+10, tri_shadow.position.y);
        }
    }
    //leftButtonをおした時の処理
    if (leftButton != nil && [leftButton containsPoint:point]) {
        if(tri.position.x > 0){
            tri.position = CGPointMake(tri.position.x-10, tri.position.y);
            tri_shadow.position = CGPointMake(tri_shadow.position.x-10, tri_shadow.position.y);
        }
    }
    

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    playerstatus = kDragStart;
    /*
    UITouch *touch = [touches anyObject];
    CGPoint touchPos = [touch locationInNode:self];
    tri.position = CGPointMake(touchPos.x, tri.position.y);
    tri_shadow.position = CGPointMake(touchPos.x, tri_shadow.position.y);
     */
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
    if(playerstatus ==! kDragStart){
        NSLog(@"touch end");
        //if(myball == nil){
            [self attack:CGPointMake(tri.position.x, tri.position.y + 10)
                 bitMask:kPlayerContactMask
             moveToPoint:CGPointMake(tri.position.x,  tri.position.y + 10 + self.frame.size.height)
             attackColor:[SKColor blueColor]
             ];
            playerstatus = kDragNone;
        //}
    }*/
}


//衝突処理
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if(contact.bodyA.node.physicsBody.categoryBitMask == kEnemyCategoryMask) {
        [attackEnemyList removeObject:contact.bodyA.node];
    } else if(contact.bodyB.node.physicsBody.categoryBitMask == kEnemyCategoryMask) {
        [attackEnemyList removeObject:contact.bodyB.node];
    }
    [contact.bodyA.node removeFromParent];
    [contact.bodyB.node removeFromParent];
    
    // 衝突した時のエフェクト
    [self showConst:contact.contactPoint];
    
    
    NSLog(@"count:%lu",(unsigned long)[attackEnemyList count]);
    if((unsigned long)[attackEnemyList count] <= 0){
        //if (self.paused == YES) {
            FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Game Clear!!!"
                                                                  message:@"おめでとうございます"
                                                                 delegate:self cancelButtonTitle:@"もう一回"
                                                        otherButtonTitles:@"タイトルに戻る", nil];
            alertView.titleLabel.textColor = [UIColor cloudsColor];
            alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
            alertView.messageLabel.textColor = [UIColor cloudsColor];
            alertView.messageLabel.font = [UIFont flatFontOfSize:14];
            alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
            alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
            alertView.defaultButtonColor = [UIColor cloudsColor];
            alertView.defaultButtonShadowColor = [UIColor asbestosColor];
            alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
            alertView.defaultButtonTitleColor = [UIColor asbestosColor];
            [alertView show];
        //}
        self.paused = YES;
    }
    
    //もしplayerが衝突するとゲームオーバー
    NSString *name = @"player";
    if(contact.bodyA.node.name == name || contact.bodyB.node.name == name){
        if (self.paused == YES) {
            FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Game Over"
                                                                  message:@"いや〜やられちゃったね"
                                                                 delegate:self cancelButtonTitle:@"もう一回"
                                                        otherButtonTitles:@"タイトルに戻る", nil];
            alertView.titleLabel.textColor = [UIColor cloudsColor];
            alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
            alertView.messageLabel.textColor = [UIColor cloudsColor];
            alertView.messageLabel.font = [UIFont flatFontOfSize:14];
            alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
            alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
            alertView.defaultButtonColor = [UIColor cloudsColor];
            alertView.defaultButtonShadowColor = [UIColor asbestosColor];
            alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
            alertView.defaultButtonTitleColor = [UIColor asbestosColor];
            [alertView show];
        }
        self.paused = YES;
    }

}

// アラートのボタンが押された時に呼ばれるデリゲート例文
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0://もう一度ボタン：画面をリセット
            [self resetNode];
            self.paused = NO;
            break;
        case 1://戻るボタン：タイトル画面に戻る
            //[self test];
            [self transition];
            self.paused = NO;
            break;
    }
}
-(void)transition{
    SKScene *titleScene = [[TitleScene alloc] initWithSize:self.size];
    SKTransition *transition = [SKTransition crossFadeWithDuration:0.2];
    [self.view presentScene:titleScene transition:transition];
}

//衝突時のエフェクト処理
- (void)showConst:(CGPoint)location
{
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:
                              [[NSBundle mainBundle] pathForResource:@"MyParticle"
                                                              ofType:@"sks"]];
    emitter.position = location;
    [self addChild:emitter];
    SKAction *seq = [SKAction sequence:@[[SKAction waitForDuration:0.15f],
                                         [SKAction removeFromParent]]];
    [emitter runAction:seq];
}


//nodeの初期化（リセット）
-(void)resetNode{
    [self removeAllChildren];
    attackEnemyList = [[NSMutableArray alloc] init];
    [self setBack];
    for(int i=0;i<4;i++) {
        [self setUpWall:30 + i*90];
    }
    [self setUpPlayer];
    [self setUpEnemy];
    [self setButton];
}



//毎フレームの処理
-(void)update:(CFTimeInterval)currentTime {
    if(self.paused == NO){
        [self checkMoveStatus];
        [self moveEnemy:currentTime];
        [self attack_enemy:currentTime bitMask:kPlayerContactMask attackColor:[SKColor blueColor]];
    }
}


//敵の動き（上下）
-(void)checkMoveStatus
{
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        if(node.position.x > 300 && status == kMoveRight) {
            status = kMoveLeft;
            [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
                node.position = CGPointMake(node.position.x, node.position.y-15);
            }];
        } else if(node.position.x < 30 && status == kMoveLeft) {
            status = kMoveRight;
            [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
                node.position = CGPointMake(node.position.x, node.position.y-15);
            }];
        }
    }];
}


//敵の動き（左右）
-(void)moveEnemy:(CFTimeInterval)currentTime
{
    if(lastMoveTime + 1.5 >= currentTime) return;
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        if(status == kMoveRight) {
            node.position = CGPointMake(node.position.x+10, node.position.y);
        } else {
            node.position = CGPointMake(node.position.x-10, node.position.y);
        }
        
    }];
    lastMoveTime = currentTime;
}



//敵の攻撃
-(void)attack_enemy:(CFTimeInterval)currentTime bitMask:(uint32_t)bitMask attackColor:(SKColor*)attackColor{
    if(lastAttackTime + 1.0 >= currentTime) return;
    NSUInteger enemyIndex = arc4random_uniform([attackEnemyList count]);
    SKNode* enemy = attackEnemyList[enemyIndex];
    CGPoint location = enemy.position;
    CGPoint moveToPoint = CGPointMake(location.x, location.y - self.frame.size.height );
    
    SKTexture *texture = [SKTexture textureWithImageNamed:@"ball"];
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithTexture:texture size:CGSizeMake(8,8)];
    ball.position = location;
    ball.physicsBody.dynamic = YES;
    ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ball.size];
    ball.physicsBody.contactTestBitMask = kEnemyContactMask;
    SKAction* bullAction = [SKAction sequence:@[[SKAction moveTo:moveToPoint duration:1.0],
                                                [SKAction removeFromParent]]];
    [ball runAction:bullAction];
    [self addChild:ball];
    lastAttackTime = currentTime;
}

//自分の攻撃
-(void)attack:(CGPoint)location bitMask:(uint32_t)bitMask moveToPoint:(CGPoint)moveToPoint attackColor:(SKColor*)attackColor
{
    SKTexture *texture = [SKTexture textureWithImageNamed:@"ball"];
        myball = [SKSpriteNode spriteNodeWithTexture:texture size:CGSizeMake(8,8)];
        myball.position = location;
        myball.physicsBody.dynamic = YES;
        myball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:myball.size];
        myball.physicsBody.contactTestBitMask = bitMask;
        [self addChild:myball];
        NSLog(@"attack");
        SKAction* bullAction = [SKAction sequence:@[[SKAction moveTo:moveToPoint duration:1.0],
                                                    [SKAction removeFromParent],
                                                    ]];
        [myball runAction:bullAction];
}


//敵の作成と配置
-(void)setUpEnemy
{
    for(int i=1;i<=5;i++) {
        for(int j=1;j<=5;j++) {
            SKSpriteNode *sprite;
            sprite = [SKSpriteNode spriteNodeWithImageNamed:@"invader1"];
            sprite.size = CGSizeMake(30, 30);
            sprite.position =CGPointMake(50+ j*50, 300 + i*50);
            sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
            sprite.physicsBody.categoryBitMask = kEnemyCategoryMask;
            //sprite.physicsBody.categoryBitMask = kEnemyMask;
            sprite.physicsBody.dynamic = NO;
            sprite.name = @"enemy";
            [self addChild:sprite];
            [attackEnemyList addObject:sprite];
        }
    }
    NSLog(@"count:%lu",(unsigned long)[attackEnemyList count]);
    //count_enemy = 25;
    count_enemy = (int)[attackEnemyList count];
}


//自機の作成と配置
-(void) setUpPlayer{
    
    UIBezierPath *path_shadow = [UIBezierPath bezierPath];
    [path_shadow moveToPoint:CGPointMake(-5, -5)];
    [path_shadow addLineToPoint:CGPointMake(15, -5)];
    [path_shadow addLineToPoint:CGPointMake(5, 15)];
    [path_shadow closePath];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(-10, 0)];
    [path addLineToPoint:CGPointMake(10, 0)];
    [path addLineToPoint:CGPointMake(0, 20)];
    [path closePath];
    
    tri_shadow = [SKShapeNode node];
    tri_shadow.name = @"player";
    tri_shadow.path = path_shadow.CGPath;
    tri_shadow.position = CGPointMake(160, 70);
    tri_shadow.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 20)];
    tri_shadow.physicsBody.categoryBitMask = kPlayerCategoryMask;
    tri_shadow.physicsBody.dynamic = NO;
    tri_shadow.fillColor = [UIColor darkGrayColor];
    tri_shadow.strokeColor = [UIColor darkGrayColor];
    [self addChild:tri_shadow];

    tri = [SKShapeNode node];
    tri.name = @"player";
    tri.path = path.CGPath;
    tri.position = CGPointMake(160, 70);
    tri.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 20)];
    tri.physicsBody.categoryBitMask = kPlayerCategoryMask;
    tri.physicsBody.dynamic = NO;
    tri.fillColor = [UIColor lightGrayColor];
    tri.strokeColor = [UIColor lightGrayColor];
    [self addChild:tri];
    
}


//背景の作成
-(void)setBack{
    SKTexture *textur = [SKTexture textureWithImageNamed:@"backImage"];
    SKSpriteNode *backImage = [[SKSpriteNode alloc] initWithTexture:textur];
    backImage.size = CGSizeMake(textur.size.width, textur.size.height);
    backImage.yScale = self.size.height / textur.size.height;
    backImage.xScale = self.size.height / textur.size.height;;
    backImage.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:backImage];
}

-(void)setButton{
    //設定ボタン
    SKTexture *textures1 = [SKTexture textureWithImageNamed:@"stopButton2"];
    settingButton = [[SKSpriteNode alloc] initWithTexture:textures1];
    settingButton.size = CGSizeMake(textures1.size.width, textures1.size.height);
    settingButton.name = @"settingButton";
    settingButton.xScale = 0.4;
    settingButton.yScale = 0.4;
    settingButton.position = CGPointMake(self.size.width*0.9, self.size.height*0.92);
    [self addChild:settingButton];
    
    //攻撃ボタン
    SKTexture *textures2 = [SKTexture textureWithImageNamed:@"attackButton1"];
    shotButton = [[SKSpriteNode alloc] initWithTexture:textures2];
    shotButton.size = CGSizeMake(textures2.size.width, textures2.size.height);
    shotButton.name = @"shotButton";
    shotButton.xScale = 0.4;
    shotButton.yScale = 0.4;
    shotButton.position = CGPointMake(self.size.width/2, self.size.height*0.05);
    [self addChild:shotButton];
    
    //右移動ボタン
    SKTexture *textures3 = [SKTexture textureWithImageNamed:@"rightButton"];
    rightButton = [[SKSpriteNode alloc] initWithTexture:textures3];
    rightButton.size = CGSizeMake(textures3.size.width, textures3.size.height);
    rightButton.name = @"rightButton";
    rightButton.xScale = 0.4;
    rightButton.yScale = 0.4;
    rightButton.position = CGPointMake(self.size.width*0.7, self.size.height*0.05);
    [self addChild:rightButton];
    
    //左移動ボタン
    SKTexture *textures4 = [SKTexture textureWithImageNamed:@"leftButton"];
    leftButton = [[SKSpriteNode alloc] initWithTexture:textures4];
    leftButton.size = CGSizeMake(textures4.size.width, textures4.size.height);
    leftButton.name = @"leftButton";
    leftButton.xScale = 0.4;
    leftButton.yScale = 0.4;
    leftButton.position = CGPointMake(self.size.width*0.3, self.size.height*0.05);
    [self addChild:leftButton];
    
}


//壁の作成
-(void) setUpWall:(int)pos_x
{
    for(int i=0;i<10;i++) {
        int start_j = 0;
        int end_j = 10;
        if( i == 0 || i == 9 ) { start_j = 2;end_j = 7;}
        if( i == 1 || i == 8 ) { start_j = 2;end_j = 8;}
        if( i == 2 || i == 7 ) { start_j = 2;end_j = 9;}
        if( i == 3 || i == 6 ) { start_j = 4;end_j = 10;}
        if( i == 4 || i == 5 ) { start_j = 5;end_j = 10;}
        for(int j=start_j;j<end_j;j++) {
            SKSpriteNode *wall = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(5,5)];
            wall.position =CGPointMake(pos_x+i*5, 100 + j*5);
            wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wall.size];
            wall.physicsBody.categoryBitMask =  kWallCategoryMask;
            wall.physicsBody.dynamic = NO;
            [self addChild:wall];
        }
    }
    
}

@end
