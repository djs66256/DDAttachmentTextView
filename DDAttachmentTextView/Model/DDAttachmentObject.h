//
//  DDAttachmentObject.h
//

#import <UIKit/UIKit.h>

@interface DDAttachmentObject : NSObject

@end

@interface DDTextAttachmentObject : DDAttachmentObject
@property (strong, nonatomic) NSString *text;
@end

@interface DDImageAttachmentObject : DDAttachmentObject
@property (strong, nonatomic) UIImage *image;
@end

@interface DDUserAttachmentObject : DDAttachmentObject
@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *detailInfo;
@end

@interface DDAttachmentObject (convertor)

+ (NSArray<DDAttachmentObject *> *)attachmentObjects;
+ (NSAttributedString *)attributedStringWithObjects:(NSArray<DDAttachmentObject *> *)objects;

@end

