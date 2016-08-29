//
//  SPMarkdownPreviewViewController.m
//  Simplenote
//
//  Created by James Frost on 01/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPMarkdownPreviewViewController.h"
#import "SPMarkdownParser.h"
#import "VSThemeManager.h"
#import "UIBarButtonItem+Images.h"
#import "UIDevice+Extensions.h"

@import SafariServices;

@interface SPMarkdownPreviewViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation SPMarkdownPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Preview", @"Title of Markdown preview screen");
    
    [self configureWebView];
    [self applyStyle];
    [self displayMarkdown];
}

- (void)configureWebView
{
    UIWebView *webView = [UIWebView new];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:webView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(webView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    if ([webView respondsToSelector:@selector(allowsLinkPreview)]) {
        webView.allowsLinkPreview = YES;
    }
    
    webView.delegate = self;
    
    self.webView = webView;
}

- (void)applyStyle
{
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    UIColor *backgroundColor = [theme colorForKey:@"backgroundColor"];
    
    self.view.backgroundColor = backgroundColor;
    self.webView.backgroundColor = backgroundColor;
    self.webView.opaque = NO;

    UIBarButtonItem *backButton = [UIBarButtonItem backBarButtonWithTitle:NSLocalizedString(@"Back", @"Title of Back button for Markdown preview")
                                                                    target:self
                                                                    action:@selector(backButtonAction:)];

    if ([UIDevice isPad]) {
        // iPad needs extra padding on the left for the back button to align with previous screens
        self.navigationItem.leftBarButtonItems = @[ [UIBarButtonItem barButtonFixedSpaceWithWidth:4], backButton ];
    } else {
        self.navigationItem.leftBarButtonItem = backButton;
    }
}

- (void)displayMarkdown
{
    NSString *html = [SPMarkdownParser renderHTMLFromMarkdownString:self.markdownText];

    [self.webView loadHTMLString:html
                         baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark - IBActions

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Prevent links from being opened within this webview.
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([SFSafariViewController class]) {
            SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[request URL]];
            [self presentViewController:sfvc animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[request URL]];
        }

        return NO;
    }
    
    return YES;
}

@end
