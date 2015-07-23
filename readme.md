#Muting calls and using the device's speaker in iOS

In this tutorial, we will be building an ordinary iOS app to phone calling app, however we will be investigating some of the cool features Sinch has addded to make muting calls and using the iOS device's speaker really easy. Today's app also has a nice UI.

![overview](/images/overview.jpg)

##Getting Started

We've prepared a starter file which can be downloaded from [here](https://github.com/sinch/ios-speaker-mute-functions). Download the project, open it and have a look around the app to get an idea of what we will be building. The app comprises of two screens, one that allows us to enter a phone number and another which dispays the current call. To save time we've set up all the actions and outlets for the views.

To get started, log into your Sinch dashboard, create a new app and get your app keys. If you don't have an account follow this [link](https://www.sinch.com) and it'll show you how to get started, it's FREE! If you verify your mobile phone number now you can get $2 worth of free calls which are pretty important if you want to try out this tutorial.

Once you've got your app keys head over to terminal on your Mac, today we're going to use cocoapods to install the Sinch framework. This is the easiest way although you've also got the option to add the framework manually. Start by using the $ cd command to navigate to your project's main directory and call $ pod init. This will create a file in your project main directory, open up the text file and add the Sinch pod.

![Podfile image](/images/podfile.jpg)

Save the podfile and head back over to the terminal and call $ pod install, this could take a little while but you'll notice that there will be a message in the terminal telling you to use the xcworkspace file instead of the traditional xcodeproj file from now on when working on the project.

##Adding Sinch
	
Once you've got the frameworks setup it's time to start coding, in the ViewController.h we need to add this line of code below `"#import <UIKit/UIKit.h>"`
``` objective-c
	#import <Sinch/Sinch.h>
```
And that's how easy it is to start using Sinch. In the ViewController.m file we then need to go ahead and make the ViewController class conform to the delegate methods for Sinch. We need to make the class conform to both the SINCallClientDelegate and SINCallDelegate. Your ViewController.h file should look something like this.

```objective-c
	#import <UIKit/UIKit.h>
	#import <Sinch/Sinch.h>
	@interface ViewController : UIViewController <SINCallClientDelegate, 	SINCallDelegate>
@end
```

Now head over to the .m counterpart and add some instance variables that Sinch will need to operate.

```objective-c
	@implementation ViewController{
    id<SINCall>_call;
    id<SINClient>_client;
	}
```

As you can see we now have a global reference to both a call and client object.

Now we will set up the Sinch client, add this method to the class. Make sure to add your app key and application secret that you got from Sinch earlier to this method, also set whether the environment is Sandbox or Production.

```objective-c

	- (void)startSinchClient {
    _client = [Sinch clientWithApplicationKey:@"YOUR-APP-KEY" applicationSecret:@"YOUR-APP-SECRET" environmentHost:@"ENVIRONMENT" userId:@"USER1"];
    [_client setSupportCalling:YES];
    [_client start];
}
```

This method starts our SINClient which we declared as in instance variable. Usually we would also add this line of code `[_client startListeningOnActiveConnection];` however we will only be making outbound calls so there's no need to listen for calls.

We now need a place to call this method from, it's best to do so from the viewDidLoad method, add a call to the startSinchClient.

```objective-c

	- (void)viewDidLoad {
    [super viewDidLoad];
    [self startSinchClient];
}
```

##Calling Functionality and UI

Now that we have established the Sinch client it's time to start calling, we've already got a method called callButton which is linked to the UI. Let's go ahead and put some code in there.

```objective-c

	- (IBAction)callButton:(id)sender {
    _call = [[_client callClient] callPhoneNumber:_numberLabel.text];
	} 
```

This is really simple, we're assigning our _call instance variable to a new call, the phone number is sourced from the text field in the initial view controller which we've already connected for you.

Although the call is being made and a segue isn't occuring and the UI isn't changing. We should change the code to present the next view programatically so we can set some variables on the screen.

Let's import the callScreenViewController into our ViewController class, it's best to import the file into our viewController.h file so it can be used in both the .h and .m files.

```objective-c
	#import "callScreenViewController.h"
```

Now create a seperate method that presents the callScreenViewController and takes an input of one NSString in the form of a phone number.

```objective-c

	- (void)presentCallScreen:(NSString *)phoneNumber {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _callScreen = (callScreenViewController *)[storyboard instantiateViewControllerWithIdentifier:@"callScreen"];
    [self presentViewController:_callScreen animated:YES completion:nil];
    _callScreen.numberLabel.text = phoneNumber;
}
```

This method accesses the view we want to present by associating the callScreen class with the storyboardId matching the view we want to present, we've already set the storyboard id for you. The last line is pretty self explanatory. We've created a `_callScreen` property so that the variable has a global scope. Add this to your properties in viewController.m

```objective-c

	@property (nonatomic, strong) callScreenViewController *callScreen;
```

Now we need to call this method from the callButton action.

```objective-c

	[self presentCallScreen:_numberLabel.text];
```

We're now going to need to use some delegates to interact with the callScreen view controller.

If you have a look at the callScreen view in the storyboard you will see we've got three buttons that need to have actions attached to them. We've got a mute button, a speakerphone button and of course a hangup button.

Let's visit callScreenViewController.h and make ourselves a protocol to manage all of this.
	
```objective-c

	@protocol callScreenDelegate <NSObject>

	-(void)mute;
	-(void)unMute;
	-(void)speaker;
	-(void)speakerOff;
	-(void)hangup;

	@end
```

This is all the functionality we need to add, now make a property for the delegate.

```objective-c

	@property (nonatomic, weak) id<callScreenDelegate> delegate;
```

Now head back over to viewController.h and make the class conform to the protocol.

```objective-c

	@interface ViewController : UIViewController <SINCallClientDelegate, SINCallDelegate, callScreenDelegate>
```
We've now got to implement the delegate methods which is the easiest part of this whole tutorial. Here's the code you will want to put in viewController.m, I'll explain after.

```objective-c
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
```

In each of the sound-related methods we get a reference to the audio controller and then send a message to the audio controller depending on what we want to do. Sinch has added some really great functionality here for us making it super-simple to use the mute function or speakerphone. If the Sinch SDK didn't do the heavy lifting for us we would have to do some serious reading into the Apple docs ourselves to make our own methods to re-route audio. Lucky for us Sinch has gotus covered.

In the hangup method we just call hangUp and call dismissViewController on the instance of callScreenViewController that we made earlier.

##Testing

Try out this code, you will notice that none of the buttons in our callScreenViewController work and there's a simple reason for it. We haven't set the our view controller as the delegate for callScreenViewController. Before the call to present the callScreenViewController in the presentCallScreen method set the delegate.

```objective-c
	_callScreen.delegate = self;
```


There's now three delegate methods that Sinch has that allow us to configure the UI at different stage. There's callDidProgress, callDidEnd and callDidEstablish. There's also another method that's used for incoming calls which we won't be needing today.

Today we're only going to implement callDidEnd and callDidEstablish. When a call ends we want to dismiss the view controller if it hasn't already been dismissed which would occur when the user on the other end of the call hangs up and the callDidEstablish method will be used to update the user interface to let us know the call has connected.

Here's the code for both of those methods.

```objective-c

- (void)callDidEstablish:(id<SINCall>)call {
    _callScreen.statusLabel.text = @"Connected!";
}
- (void)callDidEnd:(id<SINCall>)call {
    [_callScreen dismissViewControllerAnimated:YES completion:nil];
}
```
These methods won't get called at any point in the current code though, when we make a call we need to set the delegate of that call object so we can listen for events. In the callButton method edit the code to make it look like this.

```objective-c

	- (IBAction)callButton:(id)sender {
    _call = [[_client callClient] callPhoneNumber:_numberLabel.text];
    _call.delegate = self;
    _audioController = [_client audioController];
    [self presentCallScreen:_numberLabel.text];
}
```
As you can see we've set the delegate property on _call equal to self.

Now we need to provide the missing link between the callScreenViewController and the main class. In the callScreenViewController when buttons are pressed we need to call the delegate methods, update the action methods in callScreenViewController.m to match these!

```objective-c
- (IBAction)speakerButton:(id)sender {
    if (_speaker == NO) {
        _speaker = YES;
        [self.delegate speaker];
        [_speakerButton setImage:[self loadImageWithName:@"speaker_selected"] forState:UIControlStateNormal];
    } else {
        _speaker = NO;
        [self.delegate speakerOff];
        [_speakerButton setImage:[self loadImageWithName:@"speaker"] forState:UIControlStateNormal];
    }
}

- (IBAction)muteButton:(id)sender {
    if (_muted) {
        _muted = NO;
        [self.delegate unMute];
        [_muteButton setImage:[self loadImageWithName:@"mute"] forState:UIControlStateNormal];
    } else {
        _muted = YES;
        [self.delegate mute];
        [_muteButton setImage:[self loadImageWithName:@"mute_selected"] forState:UIControlStateNormal];
    }
}
- (IBAction)hangUpButton:(id)sender {
    [self.delegate hangup];
}
-(UIImage*)loadImageWithName:(NSString*)imageName
{
    NSBundle* bundle = [NSBundle bundleWithIdentifier:@"com.zac.app2phone"];
    NSString *imagePath = [bundle pathForResource:imageName ofType:@"png"];
    UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}
```

##Finishing Up

In each of the methods we've just called `[self.delegate (delegateMethod)]` and the rest is history. That's all for now, you can contact me on [twitter](http://www.twitter.com/brownzac1) with any questions or just to say hi!

You can download the finished project from the github repo [here](https://github.com/sinch/ios-speaker-mute-functions).
