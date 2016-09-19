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
    [self configureAppearance];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    PFQuery *friendsQuery = [self.friendsRelation query];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        } else {
            self.friends = objects;
        }
    }];
    
    // Launch Timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    
    //reloadEvents
    self.currentUser = [PFUser currentUser];
    self.friendsRelation = [[PFUser currentUser] relationForKey:@"friends"];
    
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mutableEvents.count;
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
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", [self.mutableEvents objectAtIndex:indexPath.row]];
    cell.subtitleLabel.text = [NSString stringWithFormat:@"%@", [self.mutableAuthor objectAtIndex:indexPath.row]];
    cell.yesButton.tag = indexPath.row;
    cell.noButton.tag = indexPath.row;
    
    if (![[[self.events valueForKey:@"acceptedUser"] objectAtIndex:indexPath.row] isEqual:[NSNull null]] &&
        [[[self.events valueForKey:@"acceptedUser"] objectAtIndex:indexPath.row] containsObject:[self.currentUser objectForKey:@"surname"]]) {
        cell.yesButton.selected = YES;
        cell.noButton.selected = NO;
    } else if (![[[self.events valueForKey:@"refusedUser"] objectAtIndex:indexPath.row] isEqual:[NSNull null]] &&
               [[[self.events valueForKey:@"refusedUser"] objectAtIndex:indexPath.row] containsObject:[self.currentUser objectForKey:@"surname"]]) {
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
    self.selectedEvent = [self.events objectAtIndex:indexPath.row];
}

- (IBAction)yesButton:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"objectId" equalTo:[[self.events objectAtIndex:[sender tag]] valueForKey:@"objectId"]];
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
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"objectId" equalTo:[[self.events objectAtIndex:[sender tag]] valueForKey:@"objectId"]];
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
    } else if ([segue.identifier isEqualToString:@"detailEvent"]) {
        EventDetailViewController *viewController = (EventDetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        viewController.event = [self.events objectAtIndex:indexPath.row];
        viewController.currentUser = self.currentUser;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    PFUser *user = [[self.events valueForKey:@"fromUserId"] objectAtIndex:indexPath.row];
    if ([user  isEqual: [[PFUser currentUser] objectId]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        PFObject *object = [self.events objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.mutableEvents removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self reloadEvents];
            } else {
                NSLog(@"error");
            }
        }];
    }
}

- (void)reloadEvents {
    PFQuery *eventsQuery = [PFQuery queryWithClassName:@"Events"];
    [eventsQuery whereKey:@"toUserId" equalTo:[[PFUser currentUser] objectId]];
    [eventsQuery orderByAscending:@"date"];
    if (eventsQuery) {
        [eventsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            } else {
                // We found messages!
                self.events = objects;
                self.eventsTitle = [self.events valueForKey:@"question"];
                self.mutableEvents = [[NSMutableArray alloc] initWithArray:self.eventsTitle];
                self.author = [self.events valueForKey:@"fromUser"];
                self.mutableAuthor = [[NSMutableArray alloc] initWithArray:self.author];
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

@end
