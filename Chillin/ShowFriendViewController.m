//
//  ShowFriendViewController.m
//  Chillin
//
//  Created by Vincent Jardel on 07/10/2016.
//  Copyright © 2016 Vincent Jardel. All rights reserved.
//

#import "ShowFriendViewController.h"
#import "AddGroupViewController.h"

@interface ShowFriendViewController ()

@end

@implementation ShowFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recipientId = [[NSMutableArray alloc] init];
    self.recipientUser = [[NSMutableArray alloc] init];
    [self loadGroup];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segment.selectedSegmentIndex == 0) {
        return [self.friendsList count];
    } else if (self.segment.selectedSegmentIndex == 1) {
        return [self.groupList count];
    }
    [tableView reloadData];
    return 0;
}

- (IBAction)segmentValueChanged:(id)sender {
    [self.tableView reloadData];
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
    if (self.segment.selectedSegmentIndex == 0) {
        NSString *name = [[self.friendsList objectAtIndex:indexPath.row] valueForKey:@"surname"];
        cell.textLabel.text = name;
    } else if (self.segment.selectedSegmentIndex == 1) {
        cell.textLabel.text = [[self.groupList objectAtIndex:indexPath.row] valueForKey:@"name"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (self.segment.selectedSegmentIndex == 0) {
        PFUser *user = [self.friendsList objectAtIndex:indexPath.row];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.recipientId addObject:user.objectId];
            [self.recipientUser addObject:user[@"surname"]];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.recipientId removeObject:user.objectId];
            [self.recipientUser removeObject:user[@"surname"]];
        }
    } else if (self.segment.selectedSegmentIndex == 1) {
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.recipientId addObject:[[self.groupList objectAtIndex:indexPath.row] objectForKey:@"recipientId"]];
            [self.recipientUser addObject:[[self.groupList objectAtIndex:indexPath.row] objectForKey:@"userSurname"]];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.recipientId removeObject:[[self.groupList objectAtIndex:indexPath.row] objectForKey:@"recipientId"]];
            [self.recipientUser removeObject:[[self.groupList objectAtIndex:indexPath.row] objectForKey:@"userSurname"]];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake([Screen width]-36, 2, 26, 26)];
    [addButton addTarget:self
               action:@selector(addGroupButton)
     forControlEvents:UIControlEventTouchUpInside];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    addButton.layer.cornerRadius = addButton.frame.size.height/2.0;
    addButton.clipsToBounds = YES;
    addButton.backgroundColor = [UIColor redColor];
    [view addSubview:addButton];
    if (self.segment.selectedSegmentIndex == 0) {
        [label setText:Localized(@"headerSectionFriend")];
        addButton.hidden = YES;
    } else if (self.segment.selectedSegmentIndex == 1) {
        [label setText:@"Je l'envoie au groupe :"];
        addButton.hidden = NO;
    }
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorChillin]];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 30;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segment.selectedSegmentIndex == 1) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        PFObject *object = self.groupList[indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self loadGroup];
            } else {
                NSLog(@"error");
            }
        }];
    }
}

- (IBAction)sendEvent:(id)sender {
    if (self.recipientId.count != 0) {
        [self.eventObject setObject:self.currentUser.objectId forKey:@"fromUserId"];
        [self.eventObject setObject:self.currentUser[@"surname"] forKey:@"fromUser"];
        [self.eventObject addObject:[self.currentUser objectForKey:@"surname"] forKey:@"acceptedUser"];
        if (self.segment.selectedSegmentIndex == 0) {
            [self.eventObject setObject:self.recipientId forKey:@"toUserId"];
            [self.eventObject setObject:self.recipientUser forKey:@"toUser"];
        } else if (self.segment.selectedSegmentIndex == 1) {
            [self.eventObject setObject:[self.recipientId valueForKeyPath:@"@unionOfArrays.self"] forKey:@"toUserId"];
            [self.eventObject setObject:[self.recipientUser valueForKeyPath:@"@unionOfArrays.self"] forKey:@"toUser"];
        }

        [self.eventObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                    message:@"Please try sending your event again."
                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                NSMutableArray *pushNotifId;
                if (self.segment.selectedSegmentIndex == 0) {
                    pushNotifId = self.recipientId;
                    [pushNotifId removeObjectAtIndex:0];
                } else if (self.segment.selectedSegmentIndex == 1) {
                    pushNotifId = [self.recipientId valueForKeyPath:@"@unionOfArrays.self"];
                    NSLog(@"%@", [self.recipientId valueForKeyPath:@"@unionOfArrays.self"]);
                    [pushNotifId removeObjectAtIndex:0];
                }
                
                NSMutableDictionary * params = [NSMutableDictionary new];
                params[@"userId"] = pushNotifId;
                params[@"eventId"] = self.eventObject.objectId;
                [PFCloud callFunctionInBackground:@"pushEventNotification" withParameters:params block:^(id object, NSError *error) {
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

- (void)addGroupButton {
    [self performSegueWithIdentifier:@"addGroup" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addGroup"]) {
        AddGroupViewController *viewController = (AddGroupViewController *)segue.destinationViewController;
        viewController.friendsList = self.friendsList;
    }
}

- (void)loadGroup {
    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery whereKey:@"fromUserId" equalTo:[[PFUser currentUser] objectId]];
    if (groupQuery) {
        [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            } else {
                self.groupList = objects;
                [self.tableView reloadData];
            }
        }];
    }
}

@end
