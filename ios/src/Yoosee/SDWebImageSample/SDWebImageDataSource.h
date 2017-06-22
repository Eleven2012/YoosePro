//
//  SDWebImageDataSource.h
//  Sample
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"


@interface SDWebImageDataSource : NSObject <KTPhotoBrowserDataSource>
@property (nonatomic, strong) NSMutableArray *screenshotPaths;
@end
