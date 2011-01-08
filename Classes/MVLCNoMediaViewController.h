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
	UILabel * _titleLabel;
}
@property (nonatomic, retain) IBOutlet UILabel * explanationLabel;
@property (nonatomic, retain) IBOutlet UILabel * titleLabel;
@end
