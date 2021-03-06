/*******************************************************************************
 *
 * Copyright 2013 Bess Siegal
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/


#import "GameOverScene.h"
#import "IntroLayer.h"
#import <UIKit/UIKit.h>
#import "SimpleAudioEngine.h"

@implementation GameOverScene
@synthesize layer = _layer;

-(id) init {
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
        [self addChild:_layer];
    }
    return self;
}

-(void) dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}
@end


@implementation GameOverLayer

CCLabelTTF* _yourScore;
CCLabelTTF* _hiScore;

-(id) init {
    if (self = [super init]) {
        
        CCSprite* background = [Make10Util genLayerBackgroundWithName:@"gameOverBg"];
        [self addChild:background];
        
        CCSprite* score = [Make10Util createWhiteBoxSprite];
        [self addChild:score];

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _yourScore = [CCLabelTTF labelWithString:@"" fontName:@"American Typewriter" fontSize:[Make10Util getTitleFontSize]];
        _yourScore.color = ccc3(0, 0, 0);
        _yourScore.position = ccp(winSize.width / 2, winSize.height - [Make10Util getMarginTop] - [Make10Util getUpperLabelPadding] - [Make10Util getScoreLabelHeight] / 2);
        [self addChild:_yourScore];
        

        CCLabelTTF* gameOver = [CCLabelTTF labelWithString:@"Game Over" fontName:@"American Typewriter" fontSize:[Make10Util getTitleFontSize]];
//        gameOver.color = ccc3(0, 0, 0);
        gameOver.position = ccp(winSize.width / 2, winSize.height * (0.8));
        [self addChild:gameOver];
        
        _hiScore = [CCLabelTTF labelWithString:@"" fontName:@"American Typewriter" fontSize:[Make10Util getTitleFontSize]];
//        _hiScore.color = ccc3(0, 0, 0);
        _hiScore.position = ccp(winSize.width / 2, winSize.height * (0.6));
        [self addChild:_hiScore];
        
        _home = [Make10Util createHomeSprite];
//        NSLog(@"GameOverLayer.init _home = %@", _home);
        [self addChild:_home];
        self.isTouchEnabled = YES;
    }
    return self;
}

-(void) setScore:(int)score {
    
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    [formatter setGroupingSize:3];
    [formatter setAlwaysShowsDecimalSeparator:NO];
    [formatter setUsesGroupingSeparator:YES];
    
    [_yourScore setString:[NSString stringWithFormat:@"%@", [formatter stringFromNumber:[NSNumber numberWithInt:score]]]];
    

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber* highScore = [defaults objectForKey:PREF_HIGH_SCORE];
    if (!highScore || score > [highScore intValue]) {
        
        [_hiScore setString:@"Congratulations!\nA new high!"];
        
        [defaults setInteger:score forKey:PREF_HIGH_SCORE];
        
    } else if (score == [highScore intValue]) {
        
        [_hiScore setString:@"Congratulations!\nTied the high!"];
        
    } else {
        
        [_hiScore setString:[NSString stringWithFormat:@"High score: %@", [formatter stringFromNumber:[NSNumber numberWithInt:[highScore intValue]]]]];
    }
    
    [formatter release];

}

#pragma mark Touches

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([Make10Util isSpriteTouched:_home touches:touches]) {
        [Make10Util touchSpriteBegan:_home];
    }
}

-(void) ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if ([Make10Util isSpriteTouched:_home touches:touches]) {
        [Make10Util touchedSprite:_home target:self selector:@selector(homeAction)];
        return;
    }
    
    /*
     * In case moved off
     */
    [Make10Util touchSpriteEnded:_home];

}

-(void) homeAction {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:LAYER_TRANS_TIME scene:[IntroLayer scene]]];
    
}
//-(void) onExit {
//    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"gameOverBg.plist"];
//    [super onExit];
//}

-(void) dealloc {
//    NSLog(@"GameOverScene dealloc");
    self.isTouchEnabled = NO;
    
    [_yourScore removeFromParentAndCleanup:YES];
    _yourScore = nil;
    [_hiScore removeFromParentAndCleanup:YES];
    _hiScore = nil;
    [_home removeFromParentAndCleanup:YES];
    _home = nil;
    
    [self removeFromParentAndCleanup:YES];
    [super dealloc];
}
@end
