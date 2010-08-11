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
	AQGridView *     _gridView;
	NSMutableArray * _allMedia;
}
@property (nonatomic, retain) IBOutlet AQGridView *gridView;
@end
