//
// Created by Dmitry on 23.08.15.
// Copyright (c) 2015 Home. All rights reserved.
//

#import "VideoStreamViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoStreamView.h"
#import "AVURLAsset+URLSchemeModifier.h"

@interface VideoStreamViewController () <AVAssetResourceLoaderDelegate>

@property (nonatomic, weak) IBOutlet VideoStreamView *playerView;
@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) BOOL isPlaying;

- (void)setupPlayer;
- (IBAction)switchPlayPause;

@end

@implementation VideoStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPlayer];
    [self setIsPlaying:YES];
}

- (void)setupPlayer {
    AVURLAsset *asset = [AVURLAsset cachedURLAssetWithURL:self.sourceURL options:nil];
    NSLog(@"Resource loader delegate: %@, queue: %@", asset.resourceLoader.delegate, asset.resourceLoader.delegateQueue);
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.playerView setPlayer:player];
    self.player = player;
}

- (void)switchPlayPause {
    self.isPlaying = !self.isPlaying;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (isPlaying) {
        [self.player play];
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else {
        [self.player pause];
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    _isPlaying = isPlaying;
}

@end