//
//  MobileVLCAppDelegate.h
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVLCMovieViewController.h"

@interface MobileVLCAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *                _window;
	MVLCMovieViewController * _movieViewController;
}
@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet MVLCMovieViewController * movieViewController;
@end
