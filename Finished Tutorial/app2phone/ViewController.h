//
//  ViewController.h
//  app2phone
//
//  Created by Zachary Brown on 6/05/2015.
//  Copyright (c) 2015 Zac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Sinch/Sinch.h>
#import "callScreenViewController.h"
@interface ViewController : UIViewController <SINCallClientDelegate, SINCallDelegate,  callScreenDelegate>
//sinclientdelegate added

@end

