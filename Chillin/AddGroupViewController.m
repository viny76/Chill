//
//  AddGroupViewController.m
//  Chillin
//
//  Created by Vincent Jardel on 12/10/2016.
//  Copyright © 2016 Vincent Jardel. All rights reserved.
//

#import "AddGroupViewController.h"
#import "Screen.h"
#import "UIColor+CustomColors.h"
#import <Parse.h>
#import "ShowFriendViewController.h"

@interface AddGroupViewController ()

@end

@implementation AddGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recipientId = [[NSMutableArray alloc] init];
    self.recipientUser = [[NSMutableArray alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1] isKindOfClass:[ShowFriendViewController class]]) {
        ShowFriendViewController *viewController = (ShowFriendViewController*)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1];
        [viewController loadGroup];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSString *name = [[self.friendsList objectAtIndex:indexPath.row] valueForKey:@"surname"];
    cell.textLabel.text = name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friendsList objectAtIndex:indexPath.row];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipientId addObject:user.objectId];
        [self.recipientUser addObject:user[@"surname"]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipientId removeObject:[PFUser currentUser].objectId];
        [self.recipientUser removeObject:user[@"surname"]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    [label setText:@"Nom du groupe : "];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorChillin]];
    // Add UITextField
    CGSize textSize = [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    CGFloat strikeWidth = textSize.width;
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(strikeWidth+10, 2, 120, 26)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.font = [UIFont systemFontOfSize:15];
    self.textField.placeholder = @"enter text";
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.delegate = self;
    [view addSubview:self.textField];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (IBAction)createGroup:(id)sender {
    if (self.recipientId.count != 0) {
        PFObject *object = [PFObject objectWithClassName:@"Group"];
        [object setObject:self.textField.text forKey:@"name"];
        [object setObject:[PFUser currentUser].objectId forKey:@"fromUserId"];
        [object setObject:self.recipientId forKey:@"recipientId"];
        [object setObject:self.recipientUser forKey:@"userSurname"];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [[self navigationController] popViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Veuillez vérifier votre connexion internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                alert.tag = 100;
                [alert show];
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Veuillez séléctionner au moins un ami" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 101;
        [alert show];
    }
}

@end
