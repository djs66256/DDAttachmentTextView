//
//  DDTextAttachment.h
//

#import <UIKit/UIKit.h>

@interface DDTextAttachment : NSTextAttachment

@property (copy, nonatomic) NSString *placeholderString;
@property (strong, nonatomic) id data;

@property (assign, nonatomic) BOOL fillWidth;
@property (assign, nonatomic) UIEdgeInsets contentInset;
@property (assign, nonatomic) CGSize size;

@end
