//
//  ViewController.m
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "AddEventsViewController.h"
#import <SevenSwitch.h>

@interface AddEventsViewController () <UIScrollViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, HSDatePickerViewControllerDelegate>
@end

@implementation AddEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.sendButton sizeToFit];
    scrollingProgrammatically = false;
    self.currentUser = [PFUser currentUser];
    //Hide Keyboard when tapping other area
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    //IMPORTANT !!!
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    self.recipientId = [[NSMutableArray alloc] init];
    self.recipientUser = [[NSMutableArray alloc] init];
    [self loadFriends];
    
    self.mySwitch.on = YES;
    [self.selectFriendButton setImage:[UIImage imageNamed:@"ChevronBottomBlue"] forState:UIControlStateNormal];
    [self.selectFriendButton setImage:[UIImage imageNamed:@"ChevronUpBlue"] forState:UIControlStateSelected];
    // Add a bottomBorder.
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.backgroundColor = [[UIColor colorBorder] CGColor];
//    bottomBorder.frame = CGRectMake(0, 0.66*[Screen height]-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height, [Screen width], 1.0f);
//    [self.headerView.layer addSublayer:bottomBorder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if(!scrollingProgrammatically) {
            if (scrollView.contentOffset.y >= self.headerView.frame.origin.y && scrollView.contentOffset.y > 0) {
                // Reach details content view
                self.selectFriendButton.selected = true;
            }
            else {
                self.selectFriendButton.selected = false;
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    scrollingProgrammatically = false;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendsList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSString *name = [[self.friendsList objectAtIndex:indexPath.row] valueForKey:@"surname"];
    cell.textLabel.text = name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friendsList objectAtIndex:indexPath.row];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipientId addObject:self.currentUser.objectId];
        [self.recipientId addObject:user.objectId];
        [self.recipientUser addObject:user[@"surname"]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipientId removeObject:user.objectId];
        [self.recipientId removeObject:self.currentUser.objectId];
        [self.recipientUser removeObject:user[@"surname"]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setText:Localized(@"headerSectionFriend")];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorChillin]];
    return view;
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
    NSLog(@"%@", self.selectedDate);
}

//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    //    NSLog(@"Picker did dismiss with %lu", (unsigned long)method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    //  NSLog(@"Picker will dismiss with %lu", (unsigned long)method);
}

- (void)loadFriends {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.navigationItem.rightBarButtonItem.enabled = false;
    self.friendsRelation = [self.currentUser relationForKey:@"friends"];
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"surname"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
            [self.hud removeFromSuperview];
        } else {
            self.friendsList = objects;
            [self.tableView reloadData];
            self.navigationItem.rightBarButtonItem.enabled = true;
            [self.hud removeFromSuperview];
            self.friendHeight.constant = self.tableView.contentSize.height;
        }
    }];
}

- (IBAction)scrollToFriend:(id)sender {
    if (!self.selectFriendButton.selected) {
        scrollingProgrammatically = true;
        [self.scrollView setContentOffset:CGPointMake(0, self.friendView.frame.origin.y) animated:YES];
        //            UIView.animateWithDuration(0.1, animations: {
        //                self.gradientViewIphone.alpha = 0.0
        //            })
        self.selectFriendButton.selected = true;
    } else {
        scrollingProgrammatically = true;
        [self.scrollView scrollRectToVisible:self.headerView.frame animated:YES];
        //            gradientViewIphone.alpha = 1
        self.selectFriendButton.selected = false;
    }
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
    else if ([self.dateButton.titleLabel.text isEqualToString:Localized(@"Select Date")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Select Date") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 101;
        [alert show];
        ok = NO;
    }
    
    // Check Friend
    else if (self.recipientId.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Select Friend(s)") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 102;
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
    else if (alertView.tag == 102) {
        if (buttonIndex == 0) {
            scrollingProgrammatically = true;
            [self.scrollView setContentOffset:CGPointMake(0, self.friendView.frame.origin.y) animated:YES];
            self.selectFriendButton.selected = true;
        }
    }
}

- (IBAction)sendEvent:(id)sender {
    if ([self verifications]) {
        NSLog(@"%@", self.recipientId);
        PFObject *events = [PFObject objectWithClassName:@"Events"];
        [events setObject:self.currentUser.objectId forKey:@"fromUserId"];
        [events setObject:self.currentUser[@"surname"] forKey:@"fromUser"];
        [events setObject:self.recipientId forKey:@"toUserId"];
        [events setObject:self.recipientUser forKey:@"toUser"];
        [events setObject:self.questionTextField.text forKey:@"question"];
        [events setObject:[NSNumber numberWithBool:[self.mySwitch isOn]] forKey:@"visibility"];
        [events addObject:[self.currentUser objectForKey:@"surname"] forKey:@"acceptedUser"];
        [events setObject:self.selectedDate forKey:@"date"];
        [events saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                    message:@"Please try sending your event again."
                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                NSMutableArray *pushNotifId = self.recipientId;
                [pushNotifId removeObjectAtIndex:0];
                [PFCloud callFunctionInBackground:@"pushEventNotification" withParameters:@{@"userId" : pushNotifId} block:^(id object, NSError *error) {
                    if (!error) {
                        NSLog(@"YES");
                        AppDelegate *appDelegateTemp = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                        appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again !" message:@"Check your network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }];
            }
        }];
    }
}

@end
