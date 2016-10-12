//
//  ShowFriendViewController.h
//  Chillin
//
//  Created by Vincent Jardel on 07/10/2016.
//  Copyright © 2016 Vincent Jardel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse.h>
#import <MBProgressHUD.h>
#import "AppDelegate.h"

@interface ShowFriendViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) PFObject *eventObject;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) NSArray *groupList;
@property (strong, nonatomic) NSMutableArray *recipientId;
@property (strong, nonatomic) NSMutableArray *recipientUser;
@property (strong, nonatomic) NSString *fromUserId;
@property (strong, nonatomic) NSString *fromUser;
@property (strong, nonatomic) NSString *toUserId;
@property (strong, nonatomic) NSString *toUser;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) PFRelation *friendsRelation;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

- (void)loadGroup;

@end
