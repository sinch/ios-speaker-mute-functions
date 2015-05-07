//
//  callScreenViewController.m
//  app2phone
//
//  Created by Zachary Brown on 6/05/2015.
//  Copyright (c) 2015 Zac. All rights reserved.
//

#import "callScreenViewController.h"

@interface callScreenViewController ()
@property (nonatomic) BOOL speaker;
@property (nonatomic) BOOL muted;
@end

@implementation callScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _speaker = NO;
    _muted = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)speakerButton:(id)sender {
    if (_muted) {
        _muted = NO;
        [_muteButton setImage:[self loadImageWithName:@"mute"] forState:UIControlStateNormal];
    } else {
        _muted = YES;
        [_muteButton setImage:[self loadImageWithName:@"mute_selected"] forState:UIControlStateNormal];
    }}

- (IBAction)muteButton:(id)sender {
    if (_muted == NO) {
        _muted = YES;
        [_muteButton setImage:[self loadImageWithName:@"mute_selected"] forState:UIControlStateNormal];
    } else {
        _muted = NO;
        [_muteButton setImage:[self loadImageWithName:@"mute"] forState:UIControlStateNormal];
    }
}
- (IBAction)hangUpButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UIImage*)loadImageWithName:(NSString*)imageName
{
    NSBundle* bundle = [NSBundle bundleWithIdentifier:@"com.zac.app2phone"];
    NSString *imagePath = [bundle pathForResource:imageName ofType:@"png"];
    UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
