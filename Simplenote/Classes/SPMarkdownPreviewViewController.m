//
//  SPMarkdownPreviewViewController.m
//  Simplenote
//
//  Created by James Frost on 01/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPMarkdownPreviewViewController.h"
#import "SPMarkdownParser.h"
#import "Simplenote-Swift.h"

@import WebKit;
@import SafariServices;

@interface SPMarkdownPreviewViewController () <WKNavigationDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) SPBlurEffectView  *navigationBarBackground;
@property (nonatomic, strong) WKWebView         *webView;
@end

@implementation SPMarkdownPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Preview", @"Title of Markdown preview screen");
    
    [self configureNavigationBarBackground];
    [self configureWebView];
    [self configureLayout];
    [self applyStyle];
    [self displayMarkdown];
}

- (void)configureNavigationBarBackground
{
    NSAssert(self.navigationBarBackground == nil, @"NavigationBarBackground was already initialized!");
    self.navigationBarBackground = [SPBlurEffectView navigationBarBlurView];
}

- (void)configureWebView
{
    NSAssert(self.webView == nil, @"WebView was already initialized!");

    WKPreferences *prefs = [WKPreferences new];
    prefs.javaScriptEnabled = NO;

    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.preferences = prefs;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    webView.opaque = NO;
    webView.allowsLinkPreview = YES;
    webView.scrollView.delegate = self;
    webView.navigationDelegate = self;
    self.webView = webView;
}

- (void)configureLayout
{
    NSAssert(self.webView != nil, @"WebView wasn't properly initialized!");
    NSAssert(self.navigationBarBackground != nil, @"NavigationBarBackground wasn't properly initialized!");

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.navigationBarBackground.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.webView];
    [self.view addSubview:self.navigationBarBackground];

    [NSLayoutConstraint activateConstraints:@[
        [self.navigationBarBackground.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.navigationBarBackground.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.navigationBarBackground.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.navigationBarBackground.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [self.webView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.webView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)applyStyle
{
    UIColor *backgroundColor = [UIColor simplenoteBackgroundColor];
    
    self.view.backgroundColor = backgroundColor;
    self.webView.backgroundColor = backgroundColor;
}

- (void)displayMarkdown
{
    NSString *html = [SPMarkdownParser renderHTMLFromMarkdownString:self.markdownText];

    [self.webView loadHTMLString:html
                         baseURL:[[NSBundle mainBundle] bundleURL]];
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Slowly Fade-In the NavigationBar's Blur
    [self.navigationBarBackground adjustAlphaMatchingContentOffsetOf:scrollView];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL* targetURL = navigationAction.request.URL;
    NSURL* bundleURL = NSBundle.mainBundle.bundleURL;
    BOOL isAnchorURL = targetURL != nil && [targetURL.absoluteString containsString:bundleURL.absoluteString];

    /// Detect scenarios such as markdown/#someInternalLink
    ///
    if (navigationAction.navigationType != WKNavigationTypeLinkActivated || isAnchorURL) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    if (targetURL.isSimplenoteURL) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [[UIApplication sharedApplication] openURL:targetURL options:@{} completionHandler:nil];
        return;
    }


    if ([WKWebView handlesURLScheme:targetURL.scheme]) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:targetURL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [UIApplication.sharedApplication openURL:targetURL options:@{} completionHandler:nil];
    }

    decisionHandler(WKNavigationActionPolicyCancel);
}

#pragma mark - Traits

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 13.0, *)) {
        if ([previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:self.traitCollection] == false) {
            return;
        }

        [self displayMarkdown];
    }
}

@end
