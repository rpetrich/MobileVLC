//
//  MVLCMovieListViewController.h
//  MobileVLC
//
//  Created by Romain Goyet on 12/07/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "MVLCNoMediaViewController.h"

@interface MVLCMovieListViewController : UIViewController <AQGridViewDataSource, AQGridViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	AQGridView *      _gridView;  // Used on the iPad
	UITableView *     _tableView; // Used on the iPhone
	NSMutableArray *  _allMedia;
	CGAffineTransform _lastTransform;
}
@property (nonatomic, retain) IBOutlet MVLCNoMediaViewController * noMediaViewController;
- (IBAction)showAboutScreen:(id)sender;
- (void)reloadMedia;
@end
