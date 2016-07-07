//
//  DDAttachmentLayoutManager.h
//

#import <UIKit/UIKit.h>

@protocol DDAttachmentLayoutManagerDelegate;
@class DDTextAttachment;
@interface DDAttachmentLayoutManager : NSLayoutManager

@property (weak, nonatomic) id<DDAttachmentLayoutManagerDelegate> attachmentDelegate;

@end

@protocol DDAttachmentLayoutManagerDelegate <NSObject>

- (UIView *)attachmentLayoutManager:(DDAttachmentLayoutManager *)manager viewForAttachment:(DDTextAttachment *)attachment;

@end
