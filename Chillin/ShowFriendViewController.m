//
//  ShowFriendViewController.m
//  Chillin
//
//  Created by Vincent Jardel on 07/10/2016.
//  Copyright © 2016 Vincent Jardel. All rights reserved.
//

#import "ShowFriendViewController.h"

@interface ShowFriendViewController ()

@end

@implementation ShowFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recipientId = [[NSMutableArray alloc] init];
    self.recipientUser = [[NSMutableArray alloc] init];
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

- (IBAction)sendEvent:(id)sender {
    if (self.recipientId.count != 0) {
        [self.eventObject setObject:self.currentUser.objectId forKey:@"fromUserId"];
        [self.eventObject setObject:self.currentUser[@"surname"] forKey:@"fromUser"];
        [self.eventObject addObject:[self.currentUser objectForKey:@"surname"] forKey:@"acceptedUser"];
        [self.eventObject setObject:self.recipientId forKey:@"toUserId"];
        [self.eventObject setObject:self.recipientUser forKey:@"toUser"];
        [self.eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"ERROR") message:Localized(@"Select Friend(s)") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 102;
        [alert show];
    }
}

@end
