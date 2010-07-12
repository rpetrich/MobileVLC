//
//  MobileVLCAppDelegate.h
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVLCMovieListViewController.h"
#import "MVLCMovieViewController.h"

@interface MobileVLCAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *                    _window;
	MVLCMovieViewController *     _movieViewController;
	MVLCMovieListViewController * _movieListViewController;
}
@property (nonatomic, retain) IBOutlet UIWindow *                    window;
@property (nonatomic, retain) IBOutlet MVLCMovieViewController *     movieViewController;
@property (nonatomic, retain) IBOutlet MVLCMovieListViewController * movieListViewController;
@end
