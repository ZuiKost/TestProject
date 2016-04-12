//
//  CZFileTableViewCell.m
//  TestTask
//
//  Created by constantine on 09.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import "CZFileTableViewCell.h"

@implementation CZFileTableViewCell

- (void)awakeFromNib {
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (IBAction)actionDownload:(UIButton *)sender {
    
    [self.delegate downloadButtonTapped:self];
}

- (IBAction)actionRemove:(UIButton *)sender {
    
    [self.delegate removeButtonTapped:self];
}

- (IBAction)actionPause:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"Pause"]) {
        [self.delegate pauseTappedTapped:self];
    } else {
        [self.delegate resumeButtonTapped:self];
    }
}
@end
