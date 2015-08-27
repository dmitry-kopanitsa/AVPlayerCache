//
//  StartViewController.m
//  AVPlayerCache
//
//  Created by Dmitry on 23.08.15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "StartViewController.h"
#import "VideoStreamViewController.h"

static NSString *kWatchVideoSegue = @"WatchVideo";

@interface StartViewController ()

@property (nonatomic, weak) IBOutlet UITextField *sourcePathField;

- (IBAction)watch;
- (void)hideKeyboard;

@end

@implementation StartViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kWatchVideoSegue]) {
        NSURL *url = sender;
        VideoStreamViewController *viewController = segue.destinationViewController;
        viewController.sourceURL = url;
    }
}

- (void)watch {
    [self hideKeyboard];
    NSString *pathString = self.sourcePathField.text;
    NSURL *url = [NSURL URLWithString:pathString];
    if (url != nil) {
        [self performSegueWithIdentifier:kWatchVideoSegue sender:url];
    }
}

- (void)hideKeyboard {
    [self.sourcePathField resignFirstResponder];
}

@end
