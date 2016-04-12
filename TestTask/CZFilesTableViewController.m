//
//  CZFilesTableViewController.m
//  TestTask
//
//  Created by constantine on 09.04.16.
//  Copyright © 2016 Constantine Zubovich. All rights reserved.
//
#import <AFNetworking.h>
#import "CZFilesTableViewController.h"
#import "CZFileTableViewCell.h"
#import "CZServerManager.h"
#import "CZSession.h"
#import "CZDownload.h"

static NSString *identifier = @"fileCell";

@interface CZFilesTableViewController () <NSURLSessionDownloadDelegate, UITableViewDelegate, CZFileCellDelegate>

@property (strong, nonatomic) NSArray *sessions;
@property (strong, nonatomic) NSURLSession *downloadSession;
@property (strong, nonatomic) NSMutableDictionary *activeDownloads;
@property (assign, nonatomic) NSInteger lastDownloadSessionIndex;


@end

@implementation CZFilesTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CZServerManager *serverManager = [[CZServerManager alloc] init];
    
    [serverManager sessionsWithURLString:@"https://devimages.apple.com.edgekey.net/wwdc-services/ftzj8e4h/6rsxhod7fvdtnjnmgsun/videos.json"
                               onSuccess:^(NSArray *sessions) {
                                   
                                   self.sessions = sessions;
                                   
                                   [self.tableView reloadData];
                                   
                               } onFailure:^(NSError *error) {
                                   NSLog(@"%@", error);
                               }];

    
    
    self.lastDownloadSessionIndex = 0;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundSessionConfigurationWithIdentifier"];

    self.downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    self.activeDownloads = [NSMutableDictionary dictionary];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.sessions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"fileCell";
    
    CZFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.delegate = self;
    
    CZSession *session = [self.sessions objectAtIndex:indexPath.row];

    cell.fileLabel.text = [NSString stringWithFormat:@"%@", session.title];
    
    BOOL showDownloadControls = NO;
    
    CZDownload *download = [self.activeDownloads objectForKey:session.downloadURL];
    
    if (download) {
        showDownloadControls = YES;
        
        cell.downloadProgressView.progress = download.progress;
        
        cell.downloadInfoLabel.text = (download.isDownloading) ? @"in the queue..." : @"Paused";
        
        NSString *title = (download.isDownloading) ? @"Pause" : @"Resume";
        
        [cell.pauseButton setTitle:title forState:UIControlStateNormal];
    }
    
    cell.downloadProgressView.hidden = !showDownloadControls;
    
    BOOL downloaded = [self localFileExistsForSession:session];
    
    cell.downloadButton.hidden = downloaded || showDownloadControls;
    cell.pauseButton.hidden = !showDownloadControls;
    
    cell.removeButton.hidden = !downloaded;
    
    cell.downloadInfoLabel.hidden = !showDownloadControls;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *originalURL = downloadTask.originalRequest.URL.absoluteString;
    
    
    NSURL *destinationURL = [self localFilePathForUrl:originalURL];
    
    if (originalURL && destinationURL) {
        
        NSLog(@"%@", destinationURL);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *error = nil;
        
        if ([fileManager fileExistsAtPath:destinationURL.path]) {
            
            
            if ([fileManager removeItemAtPath:destinationURL.path error:&error]) {
                NSLog(@"File was removed");
            } else {
                NSLog(@"File was not removed");
            }
            
        } else {
            NSLog(@"file does not ExistsAtPath");
        }

        if (error) {
            
            NSLog(@"%@", error.localizedDescription);
        } else  {
            
            [fileManager copyItemAtURL:location toURL:destinationURL error:&error];
            
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }
    
    NSString *url = downloadTask.originalRequest.URL.absoluteString;
    
    if (url) {
        self.activeDownloads[url] = nil;
        
        NSInteger index = [self sessionIndexForDownloadTask:downloadTask];
        
        
        if (index) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                
                [self downloadSessions:1];
                
            });
        }
    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString *downloadURL = downloadTask.originalRequest.URL.absoluteString;
    
    CZDownload *download = [self.activeDownloads objectForKey:downloadURL];
    
    if (downloadURL && download) {
        
        download.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
        
        NSString *totalSize = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleBinary];
        
        NSString *downloadedSize = [NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleBinary];
        
        NSInteger sessionIndex = [self sessionIndexForDownloadTask:downloadTask];
        
        CZFileTableViewCell *fileCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sessionIndex inSection:0]];
        
        if (fileCell) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [fileCell.downloadProgressView setProgress:download.progress animated:NO];
                
                NSString *formatDownloadInfo = [NSString stringWithFormat:@"Downloading %@ of %@ %.1f%%", downloadedSize, totalSize, download.progress * 100];
                
                fileCell.downloadInfoLabel.text = formatDownloadInfo;
                
            });

        }
    }
    
}

#pragma mark - CZFileCellDelegate 

- (void)downloadButtonTapped:(CZFileTableViewCell *)cell {
    
    self.lastDownloadSessionIndex++;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    CZSession *session = [self.sessions objectAtIndex:indexPath.row];
    
    [self startDownload:session];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)resumeButtonTapped:(CZFileTableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath) {
        
        CZSession *session = [self.sessions objectAtIndex:indexPath.row];
        
        [self resumeDownload:session];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
}

- (void)removeButtonTapped:(CZFileTableViewCell *)cell {
    
    NSInteger index = [[self.tableView indexPathForCell:cell] row];
    
    CZSession *session = [self.sessions objectAtIndex:index];
    
    NSString *urlString = session.downloadURL;
    
    NSURL *localUrl = [self localFilePathForUrl:urlString];
    
    NSString *path = localUrl.path;
    
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        NSLog(@"File %@ was removed", path);
    } else {
        NSLog(@"File %@ was not removed", path);
    }
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)pauseTappedTapped:(CZFileTableViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath) {
        
        CZSession *session = [self.sessions objectAtIndex:indexPath.row];
        
        [self pauseDownload:session];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

#pragma mark - Download Methods

- (void)startDownload:(CZSession *)session {
    
    CZDownload *download = [[CZDownload alloc] initWithURL:session.downloadURL];
    
    NSURL *url = [NSURL URLWithString:session.downloadURL];
    
    download.downloadTask = [self.downloadSession downloadTaskWithURL:url];
    
    [download.downloadTask resume];
    
    download.isDownloading = YES;
    
    [self.activeDownloads setObject:download forKey:download.url];
}

- (void)pauseDownload:(CZSession *)session {
    
    NSString *urlString = session.downloadURL;
    
    CZDownload *download = [self.activeDownloads objectForKey:urlString];
    
    if (download.isDownloading) {
    
        [download.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (resumeData) {
                download.resumeData = resumeData;
            }
        }];
        
        download.isDownloading = NO;
    }
}

- (void)resumeDownload:(CZSession *)session {
    
    NSString *urlString = session.downloadURL;
    
    CZDownload *download = [self.activeDownloads objectForKey:urlString];
    
    if (download) {
        
        NSData *resumeData = download.resumeData;
        
        if (resumeData) {
            
            download.downloadTask = [self.downloadSession downloadTaskWithResumeData:resumeData];
            
            [download.downloadTask resume];
            
            download.isDownloading = YES;
        } else if ([NSURL URLWithString:download.url]) {
            
            download.downloadTask = [self.downloadSession downloadTaskWithURL:[NSURL URLWithString:download.url]];
            
            [download.downloadTask resume];
            
            download.isDownloading = YES;
        }
        
    }
    
}

- (NSInteger)sessionIndexForDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    
    NSString *url = downloadTask.originalRequest.URL.absoluteString;
    
    if (url) {
        for (int index = 0; index < self.sessions.count; index++) {
            if ([url isEqualToString:[[self.sessions objectAtIndex:index] downloadURL]]) {
                return index;
            }
        }
    }
    
    return -1;
}

- (NSURL *)localFilePathForUrl:(NSString *)previewUrl {
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager]
                                    URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    NSURL *url = [NSURL URLWithString:previewUrl];
    NSString *lastPathComponent = url.lastPathComponent;
    
    
    
    if (url && lastPathComponent) {
        
        NSURL *fullURL = [documentsDirectoryURL URLByAppendingPathComponent:lastPathComponent];
        
        return fullURL;
    }
    
    return nil;
}

- (BOOL)localFileExistsForSession:(CZSession *)session {
    
    NSString *urlString = session.downloadURL;
    
    NSURL *localUrl = [self localFilePathForUrl:urlString];
    
    NSString *path = localUrl.path;
    
    BOOL isDir = NO;
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
}

#pragma mark - Actions

- (IBAction)actionAddDownloads:(UIBarButtonItem *)sender {
    
    [self downloadSessions:10];
    
}

- (void)downloadSessions:(NSInteger)quantity {
    
    NSInteger prevStart = self.lastDownloadSessionIndex;
    
    while (self.lastDownloadSessionIndex - prevStart < quantity) {
        
        CZSession *session = [self.sessions objectAtIndex:self.lastDownloadSessionIndex];
        
        if (![self.activeDownloads objectForKey:session.downloadURL]) {
            
            [self startDownload:session];
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.lastDownloadSessionIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            
        } else {
            prevStart++;
        }
        
        self.lastDownloadSessionIndex++;
    }
    
}



@end
