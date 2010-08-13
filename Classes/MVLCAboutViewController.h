//
//  MVLCAboutViewController.h
//  MobileVLC
//
//  Created by Romain Goyet on 13/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MVLCAboutViewController : UIViewController {
	UIWebView * _webView;
}
@property (nonatomic, retain) IBOutlet UIWebView * webView;
- (IBAction)dismiss:(id)sender;
@end
