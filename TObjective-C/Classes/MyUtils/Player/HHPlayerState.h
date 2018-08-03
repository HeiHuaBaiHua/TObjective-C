//
//  HHPlayerState.h
//  OneToSay
//
//  Created by HeiHuaBaiHua on 16/6/7.
//  Copyright © 2016年 Excetop. All rights reserved.
//

#ifndef HHPlayerState_h
#define HHPlayerState_h


typedef enum : NSUInteger {
    HHPlayerStateFailed,
    HHPlayerStateBuffering,
    HHPlayerStatePlaying,
    HHPlayerStatePaused,
    HHPlayerStateFinished
} HHPlayerState;

#endif
