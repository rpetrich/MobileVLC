//
//  MobileVLCAppDelegate.h
//  MobileVLC
//
//  Created by Pierre d'Herbemont on 6/27/10.
//  Copyright Applidium 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MVLCMovieListViewController.h"

@interface MobileVLCAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *                    _window;
	UINavigationController *      _navigationController;
	MVLCMovieListViewController * _movieListViewController;
}
@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet UINavigationController * navigationController;
@property (nonatomic, retain) IBOutlet MVLCMovieListViewController * movieListViewController;
@end
