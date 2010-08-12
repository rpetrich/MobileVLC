//
//  MVLCMovieListViewController.h
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"

@interface MVLCMovieListViewController : UIViewController <AQGridViewDataSource, AQGridViewDelegate> {
	AQGridView *      _gridView;
	NSMutableArray *  _allMedia;
	CGAffineTransform _lastTransform; // This is needed because the grid view has trouble laying itself out if its parent transform isn't the identity
}
@property (nonatomic, retain) IBOutlet AQGridView *gridView;
@end
