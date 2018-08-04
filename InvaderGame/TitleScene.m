//
//  TitleScene.m
//  InvaderGame
//
//  Created by shima jinsei on 2014/11/06.
//  Copyright (c) 2014年 Jinsei Shima. All rights reserved.
//

#import "TitleScene.h"
#import "GameScene.h"


@interface TitleScene(){
    SKSpriteNode *titleImage;
    SKSpriteNode *startImage;
    SKSpriteNode *backImage;
    
}
@end


@implementation TitleScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        
        //背景
        SKTexture *textur = [SKTexture textureWithImageNamed:@"backImage"];
        backImage = [[SKSpriteNode alloc] initWithTexture:textur];
        backImage.size = CGSizeMake(textur.size.width, textur.size.height);
        backImage.yScale = self.size.height / textur.size.height;
        backImage.xScale = self.size.height / textur.size.height;;
        backImage.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:backImage];
        
        //タイトル
        SKLabelNode *label1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label1.text = @"インベーダーゲーム";
        label1.fontColor = [UIColor whiteColor];
        label1.fontSize = 32;
        label1.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        //label1.size = CGSizeMake(self.frame.size.width*0.6, self.frame.size.height*0.1);
        [self addChild:label1];
        
        //スタートボタン
        SKTexture *textures = [SKTexture textureWithImageNamed:@"playButton2"];
        startImage = [[SKSpriteNode alloc] initWithTexture:textures];
        startImage.size = CGSizeMake(textures.size.width, textures.size.height);
        startImage.name = @"playButton";
        startImage.xScale = 0.6;
        startImage.yScale = 0.6;
        startImage.position = CGPointMake(self.size.width/2, self.size.height*0.3);
        [self addChild:startImage];
        
        
    }
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [[touches anyObject] locationInNode:self];
    
    //スタート画面をクリックすると、画面遷移
    if (startImage != nil && [startImage containsPoint:point]) {
        SKScene *scene = [[GameScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition crossFadeWithDuration:0.4];
        [self.view presentScene:scene transition:transition];
    }
    
    
}


@end
