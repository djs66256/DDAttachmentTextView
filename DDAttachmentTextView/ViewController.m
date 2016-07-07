//
//  ViewController.m
//

#import "ViewController.h"
#import "DDTextAttachment.h"
#import "DDAttachmentTextView.h"
#import "DDUserAttachmentView.h"
#import "DDImageAttachmentView.h"

#import "DDAttachmentObject.h"

@interface ViewController () <DDAttachmentTextViewDelegate>

@property (strong, nonatomic) DDAttachmentTextView *textView;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    _textView = [[DDAttachmentTextView alloc] initWithFrame:self.view.bounds];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _textView.delegate = self;
    [self.view addSubview:_textView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add image" style:UIBarButtonItemStylePlain target:self action:@selector(addImage)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add user" style:UIBarButtonItemStylePlain target:self action:@selector(addUser)];
    
    [self.textView registerClass:DDImageAttachmentView.class forAttachmentViewWithReuseIdentifier:@"image"];
    [self.textView registerClass:DDUserAttachmentView.class forAttachmentViewWithReuseIdentifier:@"user"];
    
    NSMutableAttributedString *text = [DDAttachmentObject attributedStringWithObjects:[DDAttachmentObject attachmentObjects]].mutableCopy;
    [text addAttributes:self.contentTextAttribute range:NSMakeRange(0, text.length)];
    self.textView.attributedText = text;
}

- (void)addImage {
    DDImageAttachmentObject *obj = [DDImageAttachmentObject new];
    obj.image = [UIImage imageNamed:@"1"];
    
    DDTextAttachment *attachment = [DDTextAttachment new];
    attachment.size = CGSizeMake(obj.image.size.width, obj.image.size.height);
    attachment.contentInset = UIEdgeInsetsMake(5, 2, 0, 2);
    attachment.data = obj;
    [self.textView insertAttachment:attachment];
}

- (void)addUser {
    DDUserAttachmentObject *obj = [DDUserAttachmentObject new];
    obj.avatarImage = [UIImage imageNamed:@"a1"];
    obj.nickName = @"高坂穗乃果";
    obj.detailInfo = @"16岁。高中二年级。μ's的发起人。无论何时都展露笑容总而言之打起精神是其长处。根据直觉和一时兴起展开行动，一旦决定了就埋头猛冲的一根筋。多多少少的困难也能凭着天生的超乐观精神一个个突破。μ's的发动机与牵引者。";
    
    DDTextAttachment *attachment = [DDTextAttachment new];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    attachment.fillWidth = YES;
    attachment.size = CGSizeMake(width-2*2, 60);
    attachment.contentInset = UIEdgeInsetsMake(5, 2, 0, 2);
    attachment.data = obj;
    [self.textView insertAttachment:attachment];
}

- (NSParagraphStyle *)contentParagraphStyle {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraph.lineSpacing = 5;
    paragraph.paragraphSpacing = 10;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentJustified;
    
    return paragraph;
}

- (NSDictionary *)contentTextAttribute {
    NSDictionary *attribute = @{
                                NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:17],
                                NSParagraphStyleAttributeName: [self contentParagraphStyle],
                                NSUnderlineStyleAttributeName: @0
                                };
    return attribute;
}

- (DDAttachmentReusableView *)textView:(DDAttachmentTextView *)textView attachmentViewWithAttachment:(DDTextAttachment *)attachment {
    if ([attachment.data isKindOfClass:[DDImageAttachmentObject class]]) {
        DDImageAttachmentView *view = [textView dequeueReusableAttachmentViewWithIdentifier:@"image"];
        view.imageView.image = ((DDImageAttachmentObject *)attachment.data).image;
        return view;
    }
    else if ([attachment.data isKindOfClass:[DDUserAttachmentObject class]]) {
        DDUserAttachmentView *view = [textView dequeueReusableAttachmentViewWithIdentifier:@"user"];
        DDUserAttachmentObject *user = attachment.data;
        view.imageView.image = user.avatarImage;
        view.nickNameLabel.text = user.nickName;
        view.detailLabel.text = user.detailInfo;
        return view;
    }
    return nil;
}

@end
