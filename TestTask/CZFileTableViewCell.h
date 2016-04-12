//
//  CZFileTableViewCell.h
//  TestTask
//
//  Created by constantine on 09.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CZFileCellDelegate;

@interface CZFileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadInfoLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (weak, nonatomic) id<CZFileCellDelegate> delegate;

- (IBAction)actionDownload:(UIButton *)sender;
- (IBAction)actionRemove:(UIButton *)sender;
- (IBAction)actionPause:(UIButton *)sender;


@end


@protocol CZFileCellDelegate <NSObject>

- (void)downloadButtonTapped:(CZFileTableViewCell *)cell;
- (void)resumeButtonTapped:(CZFileTableViewCell *)cell;
- (void)removeButtonTapped:(CZFileTableViewCell *)cell;
- (void)pauseTappedTapped:(CZFileTableViewCell *)cell;

@end