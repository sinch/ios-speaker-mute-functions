//
//  ViewController.m
//  app2phone
//
//  Created by Zachary Brown on 6/05/2015.
//  Copyright (c) 2015 Zac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *numberLabel;
@property (nonatomic, strong) callScreenViewController *callScreen;
@end

@implementation ViewController{
    id<SINCall>_call;
    id<SINClient>_client;
}
- (IBAction)callButton:(id)sender {
    
    if ([_client isStarted]) {
        _call = [[_client callClient] callPhoneNumber:_numberLabel.text];
    //set delegate - done
    _call.delegate = self;
    _numberLabel.text = @"";
    [self presentCallScreen:_numberLabel.text];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Client not started" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self clearTextBox];
}
- (void)clearTextBox {
    _numberLabel.text = @"";
}
- (void)presentCallScreen:(NSString *)phoneNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _callScreen = (callScreenViewController *)[storyboard instantiateViewControllerWithIdentifier:@"callScreen"];
    //set delegate - done
    _callScreen.delegate = self;
    [self presentViewController:_callScreen animated:YES completion:nil];
    _callScreen.numberLabel.text = phoneNumber;
     
}
- (void)startSinchClient {
    _client = [Sinch clientWithApplicationKey:@"aff5bb9e-0a7b-465b-877a-93d18323bdeb" applicationSecret:@"2ffcNXq/PEudIHOrE8b+JQ==" environmentHost:@"sandbox.sinch.com" userId:@"USER1"];
    _client.callClient.delegate = self;
    [_client setSupportCalling:YES];
    [_client start];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self startSinchClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mute {
    id<SINAudioController> audio = [_client audioController];
    [audio mute];
}
- (void)unMute {
    id<SINAudioController> audio = [_client audioController];
    [audio unmute];
}
- (void)speaker {
    id<SINAudioController> audio = [_client audioController];
    [audio enableSpeaker];
}
- (void)speakerOff {
    id<SINAudioController> audio = [_client audioController];
    [audio disableSpeaker];
}
- (void)hangup {
    [_call hangup];
    [_callScreen dismissViewControllerAnimated:YES completion:nil];
}

- (void)callDidEstablish:(id<SINCall>)call {
    _callScreen.statusLabel.text = @"Connected!";
}
- (void)callDidEnd:(id<SINCall>)call {
    [_callScreen dismissViewControllerAnimated:YES completion:nil];
}
@end
