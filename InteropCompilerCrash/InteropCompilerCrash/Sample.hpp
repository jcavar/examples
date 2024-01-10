#pragma once

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <swift/bridging>

typedef int (^SambleBlock)(AURenderPullInputBlock pullInputBlock);

SambleBlock makeRenderBlock(int y) {
    return ^int(AURenderPullInputBlock pullInputBlock) {
        return y;
    };
}
