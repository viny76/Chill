//
//  ViewController.m
//  ChillN
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCell.h"
#import "AppDelegate.h"
#import "AddEventsViewController.h"
#import "EventDetailViewController.h"
#import "CustomFonts.h"
#import "Screen.h"
#import <AddressBook/AddressBook.h>
#import "CBZSplashView.h"
#import "UIColor+CustomColors.h"

@interface HomeViewController() <UIScrollViewDelegate>
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sampleData = [[NSMutableArray alloc] init];
    [self configureAppearance];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    
    self.currentUser = [PFUser currentUser];
    [self reloadFriend];
    
    // Launch Timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    
    //reloadEvents
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl beginRefreshing];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(reloadEvents) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    if (!self.currentUser.objectId) {
        [PFUser logOut];
        AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        UIViewController *rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
        appDelegateTemp.window.rootViewController = navigation;
    } else {
        [self reloadEvents];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
    return self.sampleData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section; {
    return self.sampleData[section][@"date"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
    return [self.sampleData[section][@"group"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // iPhone 6
    if ([Screen height] > 568) {
        return ([Screen height]-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)/6;
    } else {
        return ([Screen height]-self.navigationController.navigationBar.frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)/4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"parallaxCell";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *post = self.sampleData[indexPath.section][@"group"][indexPath.row];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", [post objectForKey:@"question"]];
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@", [post objectForKey:@"fromUser"]];
    
    if (![[post objectForKey:@"acceptedUser"] isEqual:[NSNull null]] &&
        [[post objectForKey:@"acceptedUser"] containsObject:[self.currentUser objectForKey:@"surname"]]) {
        cell.yesButton.selected = YES;
        cell.noButton.selected = NO;
    } else if (![[post objectForKey:@"refusedUser"] isEqual:[NSNull null]] &&
               [[post objectForKey:@"refusedUser"] containsObject:[self.currentUser objectForKey:@"surname"]]) {
        cell.yesButton.selected = NO;
        cell.noButton.selected = YES;
    } else {
        cell.yesButton.selected = NO;
        cell.noButton.selected = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    PFObject *post = self.sampleData[indexPath.section][@"group"][indexPath.row];
    self.selectedEvent = post;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    PFObject *post = self.sampleData[indexPath.section][@"group"][indexPath.row];
    //    PFUser *user = [[self.events valueForKey:@"fromUserId"] objectAtIndex:indexPath.row];
    PFUser *user = [post objectForKey:@"fromUserId"];
    if ([user  isEqual: [[PFUser currentUser] objectId]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        PFObject *object = self.sampleData[indexPath.section][@"group"][indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.sampleData removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
                [self reloadEvents];
            } else {
                NSLog(@"error");
            }
        }];
    }
}

- (IBAction)yesButton:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"objectId" equalTo:[[[self.sampleData objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row] valueForKey:@"objectId"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if ([[object valueForKey:@"acceptedUser"] containsObject:[self.currentUser objectForKey:@"surname"]]) {
            } else if ([[object valueForKey:@"refusedUser"] containsObject:[self.currentUser objectForKey:@"surname"]]) {
                
                [object addObject:[self.currentUser objectForKey:@"surname"] forKey:@"acceptedUser"];
                [object removeObject:[self.currentUser objectForKey:@"surname"] forKey:@"refusedUser"];
            } else {
                [object addObject:[self.currentUser objectForKey:@"surname"] forKey:@"acceptedUser"];
            }
            
            [object saveInBackground];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (IBAction)noButton:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"objectId" equalTo:[[[self.sampleData objectAtIndex:indexPath.section][@"group"] objectAtIndex:indexPath.row] valueForKey:@"objectId"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if ([[object valueForKey:@"refusedUser"] containsObject:[self.currentUser objectForKey:@"surname"]]) {
            } else if ([[object valueForKey:@"acceptedUser"] containsObject:[self.currentUser objectForKey:@"surname"]]) {
                [object removeObject:[self.currentUser objectForKey:@"surname"] forKey:@"acceptedUser"];
                [object addObject:[self.currentUser objectForKey:@"surname"] forKey:@"refusedUser"];
            }
            else {
                [object addObject:[self.currentUser objectForKey:@"surname"] forKey:@"refusedUser"];
            }
            
            
            [object saveInBackground];
        } else {
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addEvents"]) {
        AddEventsViewController *viewController = (AddEventsViewController *)segue.destinationViewController;
        viewController.friendsList = self.friends;
        viewController.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"detailEvent"]) {
        EventDetailViewController *viewController = (EventDetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *post = self.sampleData[indexPath.section][@"group"][indexPath.row];
        viewController.event = post;
        viewController.currentUser = self.currentUser;
    }
}

- (void)reloadEvents {
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Events"];
    [eventsQuery whereKey:@"toUserId" equalTo:[[PFUser currentUser] objectId]];
    [eventsQuery orderByDescending:@"date"];
    if (eventsQuery) {
        [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            } else {
                // We found messages!

                // Sort array by NSDate
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                // Add the following line to display the time in the local time zone
                [formatter setTimeZone:[NSTimeZone systemTimeZone]];
                [formatter setDateFormat:@"dd/MM/yyyy"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                
                // Sparse dictionary, containing keys for "days with posts"
                NSMutableDictionary *daysWithPosts = [NSMutableDictionary dictionary];
                
                [objects enumerateObjectsUsingBlock:^(PFObject *object, NSUInteger idx, BOOL *stop) {
                    NSString *dateString = [formatter stringFromDate:[object objectForKey:@"date"]];
                    
                    // Check to see if we have a day already.
                    NSMutableArray *posts = [daysWithPosts objectForKey: dateString];
                    
                    // If not, create it
                    if (posts == nil || (id)posts == [NSNull null])
                    {
                        posts = [NSMutableArray arrayWithCapacity:1];
                        [daysWithPosts setObject:posts forKey: dateString];
                    }
                    
                    // add post to day
                    [posts addObject:object];
                }];
                
                // Sort Dictionary Keys by Date
                NSArray *unsortedSectionTitles = [daysWithPosts allKeys];
                NSArray *sortedSectionTitles = [unsortedSectionTitles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSDate *date1 = [formatter dateFromString:obj1];
                    NSDate *date2 = [formatter dateFromString:obj2];
                    return [date2 compare:date1];
                }];
                
                NSMutableArray *sortedData = [NSMutableArray arrayWithCapacity:sortedSectionTitles.count];
                
                // Put Data into correct format:
                [sortedSectionTitles enumerateObjectsUsingBlock:^(NSString *dateString, NSUInteger idx, BOOL *stop) {
                    NSArray *group = daysWithPosts[dateString];
                    NSDictionary *dictionary = @{ @"date":dateString,
                                                  @"group":group };
                    [sortedData addObject:dictionary];
                }];
                
                self.sampleData = sortedData;
                [refreshControl endRefreshing];
                [self.tableView reloadData];
                
                // Restart Timer
                self.ticks = 0;
            }
        }];
    }
}

- (void)configureAppearance {
    // Navigation bar
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]]; // this will change the back button tint
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorChillin]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.tableView.backgroundView setContentMode:UIViewContentModeScaleAspectFill];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImage *icon = [UIImage imageNamed:@"AppIcon"];
    CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:icon backgroundColor:[UIColor colorChillin]];
    
    // customize duration, icon size, or icon color here;
    splashView.animationDuration = 1.4;
    [self.view addSubview:splashView];
    [splashView startAnimation];
    
    //UIButton in UIBarButtonItem
    self.eventsButton.showsTouchWhenHighlighted = YES;
    self.eventsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.eventsButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.friendsButton.showsTouchWhenHighlighted = YES;
    self.friendsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.friendsButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.menuButton.showsTouchWhenHighlighted = YES;
}

- (void)timerTick:(NSTimer *)timer {
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
    self.ticks += 1.0;
    double seconds = fmod(self.ticks, 60.0);
    double minutes = fmod(trunc(self.ticks / 60.0), 60.0);
    double hours = trunc(self.ticks / 3600.0);
    if (hours != 0) {
        self.timerString = [NSString stringWithFormat:@"Rafraîchit il y a %2.0fh%02.0f", hours, minutes];
    } else if (minutes != 0) {
        if (minutes > 9) {
            self.timerString = [NSString stringWithFormat:@"Rafraîchit il y a %02.0fmin", minutes];
        } else {
            self.timerString = [NSString stringWithFormat:@"Rafraîchit il y a %2.0fmin", minutes];
        }
    } else {
        self.timerString = [NSString stringWithFormat:@"Rafraîchit il y a %2.0fsec", seconds];
    }
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:self.timerString];
}

- (void)reloadFriend {
    PFQuery *friendsQuery = [[self.currentUser relationForKey:@"friends"] query];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        } else {
            self.friends = objects;
        }
    }];
}

@end
