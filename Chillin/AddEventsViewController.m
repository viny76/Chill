//
//  ViewController.m
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "AddEventsViewController.h"
#import <SevenSwitch.h>
#import "ShowFriendViewController.h"

@interface AddEventsViewController () <UIAlertViewDelegate, UITextFieldDelegate, HSDatePickerViewControllerDelegate>
@end

@implementation AddEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.sendButton sizeToFit];
    
    //Hide Keyboard when tapping other area
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    //IMPORTANT !!!
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    self.mySwitch.on = YES;
    
    //UITextField Google Maps
    _txtPlaceSearch.placeSearchDelegate                 = self;
    _txtPlaceSearch.strApiKey                           = @"AIzaSyBVaaKEBzTMw52xC58U4K53_qBYBLy_9Ak";
    _txtPlaceSearch.superViewOfList                     = self.view;  // View, on which Autocompletion list should be appeared.
    _txtPlaceSearch.autoCompleteShouldHideOnSelection   = YES;
    _txtPlaceSearch.maximumNumberOfAutoCompleteRows     = 5;
}

// UITextField Google Maps
-(void)viewDidAppear:(BOOL)animated{
    //Optional Properties
    _txtPlaceSearch.autoCompleteRegularFontName =  @"HelveticaNeue-Bold";
    _txtPlaceSearch.autoCompleteBoldFontName = @"HelveticaNeue";
    _txtPlaceSearch.autoCompleteTableCornerRadius=1.0;
    _txtPlaceSearch.autoCompleteRowHeight=35;
    _txtPlaceSearch.autoCompleteTableCellTextColor=[UIColor colorWithWhite:0.131 alpha:1.000];
    _txtPlaceSearch.autoCompleteFontSize=14;
    _txtPlaceSearch.autoCompleteTableBorderWidth=1.0;
    _txtPlaceSearch.showTextFieldDropShadowWhenAutoCompleteTableIsOpen=YES;
    _txtPlaceSearch.autoCompleteShouldHideOnSelection=YES;
    _txtPlaceSearch.autoCompleteShouldHideClosingKeyboard=YES;
    _txtPlaceSearch.autoCompleteShouldSelectOnExactMatchAutomatically = YES;
    _txtPlaceSearch.autoCompleteTableFrame = CGRectMake(10, _txtPlaceSearch.frame.size.height+100.0, [Screen width]-20, 200.0);
}

- (void)dismissKeyboard {
    [self.questionTextField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return (newLength > 30) ? NO : YES; // 30 is custom value. you can use your own.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.textAlignment = NSTextAlignmentLeft;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    textField.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.rightBarButtonItem = self.sendEventButton;
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)showDatePicker:(id)sender {
    HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
    hsdpvc.delegate = self;
    [self presentViewController:hsdpvc animated:YES completion:nil];
}

// DATE PICKER
#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    // Add the following line to display the time in the local time zone
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSString* finalTime = [dateFormatter stringFromDate:date];
    [self.dateButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    self.selectedDate = [dateFormatter dateFromString:finalTime];
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    //    NSLog(@"Picker did dismiss with %lu", (unsigned long)method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    //  NSLog(@"Picker will dismiss with %lu", (unsigned long)method);
}

- (BOOL)verifications {
    BOOL ok = YES;
    
    // Check Question
    if (self.questionTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Question is empty") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 100;
        [alert show];
        ok = NO;
    }
    
    // Check Date
    else if ([self.dateButton.titleLabel.text isEqualToString:@"Choisir Date"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Select Date") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 101;
        [alert show];
        ok = NO;
    }
    
    return ok;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            [self.questionTextField becomeFirstResponder];
        }
    }
    else if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            [self showDatePicker:self.dateButton];
        }
    }
}

- (IBAction)sendEvent:(id)sender {
    if ([self verifications]) {
        [self performSegueWithIdentifier:@"showFriend" sender:self];
    }
}

#pragma mark - Place search Textfield Delegates
-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict{
    [self.view endEditing:YES];
    NSLog(@"SELECTED ADDRESS :%@",responseDict);
}
-(void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField{
    
}
-(void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField{
    
}
-(void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index{
    if(index%2==0){
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showFriend"]) {
        PFObject *events = [PFObject objectWithClassName:@"Events"];
        [events setObject:self.questionTextField.text forKey:@"question"];
        [events setObject:[NSNumber numberWithBool:[self.mySwitch isOn]] forKey:@"visibility"];
        [events setObject:self.selectedDate forKey:@"date"];
        
        ShowFriendViewController *showFriendController = [segue destinationViewController];
        showFriendController.currentUser = self.currentUser;
        showFriendController.friendsList = self.friendsList;
        showFriendController.eventObject = events;
    }
}


@end
