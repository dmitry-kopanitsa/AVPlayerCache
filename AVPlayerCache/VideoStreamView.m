//
// Created by Dmitry on 24.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "VideoStreamView.h"


@implementation VideoStreamView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

-(AVPlayer *) player{
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player {
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

@end