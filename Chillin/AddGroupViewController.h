//
//  AddGroupViewController.h
//  Chillin
//
//  Created by Vincent Jardel on 12/10/2016.
//  Copyright © 2016 Vincent Jardel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSArray *friendsList;
@property (strong, nonatomic) NSMutableArray *recipientId;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSMutableArray *recipientUser;

@end
