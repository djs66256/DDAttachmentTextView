//
//  DDAttachmentObject.m
//

#import "DDAttachmentObject.h"

@implementation DDAttachmentObject

@end

@implementation DDTextAttachmentObject

@end

@implementation DDImageAttachmentObject

@end

@implementation DDUserAttachmentObject 

@end

#import "DDTextAttachment.h"

@implementation DDAttachmentObject (convertor)

+ (NSArray<DDAttachmentObject *> *)attachmentObjects {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSMutableArray *objects = @[].mutableCopy;
    for (NSDictionary *dict in array) {
        if ([dict[@"type"] isEqualToString:@"text"]) {
            DDTextAttachmentObject *obj = [DDTextAttachmentObject new];
            obj.text = dict[@"text"];
            [objects addObject:obj];
        }
        else if ([dict[@"type"] isEqualToString:@"image"]) {
            DDImageAttachmentObject *obj = [DDImageAttachmentObject new];
            obj.image = [UIImage imageNamed:dict[@"image"]];
            [objects addObject:obj];
        }
        else if ([dict[@"type"] isEqualToString:@"user"]) {
            DDUserAttachmentObject *obj = [DDUserAttachmentObject new];
            obj.avatarImage = [UIImage imageNamed:dict[@"image"]];
            obj.nickName = dict[@"nickName"];
            obj.detailInfo = dict[@"detailInfo"];
            [objects addObject:obj];
        }
    }
    return objects;
}

+ (NSAttributedString *)attributedStringWithObjects:(NSArray<DDAttachmentObject *> *)objects {
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    for (DDAttachmentObject *obj in objects) {
        if ([obj isKindOfClass:[DDTextAttachmentObject class]]) {
            DDTextAttachmentObject *textObj = (DDTextAttachmentObject *)obj;
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:textObj.text]];
        }
        else if ([obj isKindOfClass:[DDImageAttachmentObject class]]) {
            DDImageAttachmentObject *imgObj = (DDImageAttachmentObject *)obj;
            
            DDTextAttachment *attachment = [DDTextAttachment new];
            attachment.size = CGSizeMake(imgObj.image.size.width, imgObj.image.size.height);
            attachment.contentInset = UIEdgeInsetsMake(5, 2, 0, 2);
            attachment.data = imgObj;
            [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }
        else if ([obj isKindOfClass:[DDUserAttachmentObject class]]) {
            DDUserAttachmentObject *user = (DDUserAttachmentObject *)obj;
            
            DDTextAttachment *attachment = [DDTextAttachment new];
            attachment.fillWidth = YES;
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            attachment.size = CGSizeMake(width-2*2, 60);
            attachment.contentInset = UIEdgeInsetsMake(5, 2, 0, 2);
            attachment.data = user;
            [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }
    }
    return string.copy;
}

@end