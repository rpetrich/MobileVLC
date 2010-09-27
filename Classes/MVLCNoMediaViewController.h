//
//  MVLCNoMediaViewController.h
//  MobileVLC
//
//  Created by Romain Goyet on 30/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVLCNoMediaViewController : UIViewController {
	UILabel * _explanationLabel;
}
@property (nonatomic, retain) IBOutlet UILabel * explanationLabel;
@end
