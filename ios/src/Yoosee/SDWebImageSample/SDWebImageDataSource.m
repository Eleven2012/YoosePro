//
//  SDWebImageDataSource.m
//  Sample
//

#import "SDWebImageDataSource.h"
#import "KTPhotoView+SDWebImage.h"
#import "KTThumbView+SDWebImage.h"
#import "AppDelegate.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Utils.h"

#define FULL_SIZE_INDEX 0
#define THUMBNAIL_INDEX 1

@implementation SDWebImageDataSource

- (void)dealloc {
   [super dealloc];
}

- (id)init {
   self = [super init];
   if (self) {
       
       //remove imagePaths
       [self.screenshotPaths removeAllObjects];
       
       LoginResult *loginResult = [UDManager getLoginInfo];
       //image files
       NSArray *datas = [NSArray arrayWithArray:[Utils getScreenshotFilesWithId:loginResult.contactId]];
       
       self.screenshotPaths = [NSMutableArray arrayWithCapacity:0];
       for (NSString *imageName in datas) {
           NSString *imagePath = [Utils getScreenshotFilePathWithName:imageName contactId:loginResult.contactId];
           [self.screenshotPaths addObject:imagePath];
       }
   }
   return self;
}


#pragma mark -
#pragma mark KTPhotoBrowserDataSource

- (NSInteger)numberOfPhotos {
    NSInteger count = [self.screenshotPaths count];
   return count;
}

//selected image
- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
    
    NSString *imagePath = [self.screenshotPaths objectAtIndex:index];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [photoView setImage:image];
    
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
}

//KTThumbView(UIButton) is small image in SDWebImageRootViewController
//KTThumbView is created in KTThumbsViewController(SDWebImageRootViewController)
//KTThumbView'frame is setted in KTThumbsView(UIScrollView)
//KTThumbView is also showed in KTThumbsView(UIScrollView)

//KTThumbsView(UIScrollView) is created in KTThumbsViewController
//KTThumbsView'frame is setted in
- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView {
    
    NSString *imagePath = [self.screenshotPaths objectAtIndex:index];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    [thumbView setThumbImage:image];
}

@end
