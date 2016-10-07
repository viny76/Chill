//
//  ViewController.h
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "HSDatePickerViewController.h"
#import "MVPlaceSearchTextField.h"
#import <GooglePlaces/GooglePlaces.h>

@class SevenSwitch;

@interface AddEventsViewController : UIViewController <PlaceSearchTextFieldDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MVPlaceSearchTextField *txtPlaceSearch;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) IBOutlet UITextField *questionTextField;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet SevenSwitch *mySwitch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendEventButton;
@property (strong, nonatomic) NSString *questionString;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) IBOutlet UIView *otherDetailsView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;



@end
