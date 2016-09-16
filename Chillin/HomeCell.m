//
//  HomeCell.m
//  Chillin
//
//  Created by Vincent Jardel on 26/03/2015.
//  Copyright (c) 2015 ChillCompany. All rights reserved.
//

#import "HomeCell.h"

@implementation HomeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)yesPressed:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.yesButton.selected = YES;
        self.yesButton.transform = CGAffineTransformMakeScale(6, 6);
    } completion:nil];
    
    // for zoom out
    [UIView animateWithDuration:0.5f animations:^{
        self.yesButton.transform = CGAffineTransformMakeScale(1, 1);
    }];
    self.noButton.selected = NO;
}

- (IBAction)noPressed:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.noButton.selected = YES;
        self.noButton.transform = CGAffineTransformMakeScale(6, 6);
    } completion:nil];
    
    // for zoom out
    [UIView animateWithDuration:0.5f animations:^{
        self.noButton.transform = CGAffineTransformMakeScale(1, 1);
    }];
    self.yesButton.selected = NO;
}

@end
