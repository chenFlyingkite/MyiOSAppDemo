//
// Created by Eric Chen on 2020/12/22.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import "FLViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"

@implementation FLViewController {
    bool logLife;
    bool autoEnter;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    logLife = true;
    autoEnter = true;
    if (logLife) {
        qw("V %s", "Load");
    }
    [self setupClose];
    [self setupConstraints];
    [self test];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (logLife) {
        qw("~ %s", "Appear");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (logLife) {
        qw("V %s", "Appear");
    }

    if (autoEnter) {
        autoEnter = false;
        [self onClickPress:nil];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (logLife) {
        qw("~ %s", "Layout subviews");
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (logLife) {
        qw("V %s", "Layout subviews");
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (logLife) {
        qw("~ %s", "Vanish");
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (logLife) {
        qw("V %s", "Vanish");
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIRectEdge) preferredScreenEdgesDeferringSystemGestures {
    return UIRectEdgeAll;
}

#pragma mark - View Tree
- (void) setupViewTree {

}

- (void) setupConstraints {
    UIView *parent = self.main;
    NSArray *a = @[
        [FLLayouts view:parent equalToSafeAreaOf:self.view],
    ];
    [FLLayouts activate:parent forConstraint:a];
}

- (void) setupClose {
    // Apply press color
    FLImageView *v = self.close;
    FLRes *c = [FLRes normal:@"#f00" disable:@"#ddd" pressed:@"#800" selected:@"#dd0"];
    [c applyBackgroundColorTo:v];

    UIView *parent = self.main;
    NSArray *a = @[
        [FLLayouts view:v corner:FLCornerLeftTop to:parent],
        [FLLayouts view:v width:50 height:50],
    ];
    [FLLayouts activate:parent forConstraint:a];
}

#pragma mark - ImageRequestor

- (UIViewController*) getViewController {
    return self;
}

- (void)onEditDiscard:(NSString *)from {
    self.pageEntry = nil;
}

- (void)onEditResult:(UIImage *)edited :(NSString *)from {
    //qwe("%s, %s", ssString(edited), ssString(from));
//    if (edited != NULL) {
//        [self commitUndoResult:edited withResetScale:YES];
//        if (self.pageEntry != nil) {
//            //qwe("edit call discard %s", "");
//            [self.pageEntry discardEdit:nil];
//        }
//    }
}

#pragma mark - Listeners

- (IBAction)onClickClose:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)onSeekbarValue:(id)sender {
    qw("seek v = %.2f", self.seek.value);
}
- (IBAction)onClickPress:(id)sender {
    // Bring parameter of image

    FLStoryboardInfo* args;
    args = [FLStoryboardInfo new];
    args = [FLStoryboardInfo presentFullScreen]; // FIXME : PressMe failed to click

    //[LightHitViewController presentMeWithSrc:self args:args];
    //[SurrealArtViewController presentMeWithSrc:self args:args];
    [self enterEntry];

}

- (void) enterEntry {
    // Setup entry and parameters, then we enter light hit
    SurrealArtMainEntry* e = [SurrealArtMainEntry new];
    e.sourceChanger = [LightHitTryUsersOwnPhotoAfterFeatureTryoutHandler new];
//    if (sender == nil) {
//        e.args = self.tryInfo;
//    }
    self.pageEntry = e;
    [e setRequester:self];
    //[e provideSource:self.editImage];
    //[e fastEnter];
    [e startEdit];
}

+ (FLImageView*)addEntry:(__kindof UIViewController*)parent {
    FLImageView *add = [FLImageView new];
    [FLRes applyAllTitle:@"Test UI" to:add];
    add.frame = CGRectMake(0, 50, 80, 80);
    FLRes *c = [FLRes normal:@"#800" disable:@"#888" pressed:@"#400" selected:@"#880"];
    [c applyBackgroundColorTo:add];
    //[add addTarget:self action:@selector(onEnter:) forControlEvents:UIControlEventTouchUpInside];
    [parent.view addSubview:add];
    [add bringToFront];
    return add;
}
//?
//+ (IBAction) onEnter:(id)sender {
//    [FLViewController presentMe: sender:sender];
//}

+ (void)presentMe:(__kindof UIViewController*)src sender:(id)sender{
    NSString *id = @"FLStoryboard";
    // value is in Storyboard, select ViewController, CustomClass = /className/, Storyboard Id = /vcId/
    NSString *vcId = @"FLViewController";
    [FLStoryboards goWithStoryboardFileName:id viewControllerId:vcId source:src];
}

// Old one
+ (void)presentMe2:(__kindof UIViewController*)src sender:(id)sender{
    NSString *id = @"FLStoryboard";
    // value is in Storyboard, select ViewController, CustomClass = /className/, Storyboard Id = /vcId/
    NSString *vcId = @"FLViewController";
    NSString *sid = [id addF:@"_segue"];
    //2021-01-12 17:35:20.582282+0800 photodirector[9329:1655935] global exception:Storyboard (<UIStoryboard: 0x2808d2f80>) doesn't contain a view controller with identifier 'FLStoryboard'
    UIStoryboard *board = [UIStoryboard storyboardWithName:id bundle:nil];
    printf("1");
    FLViewController *vc = [board instantiateViewControllerWithIdentifier:vcId];
    printf("2");

    UIStoryboardSegue* segue = [UIStoryboardSegue segueWithIdentifier:sid source:src destination:vc performHandler:^{
        printf("5");
        // View did load
        [src presentViewController:vc animated:NO completion:nil];
        printf("6");
    }];
    printf("3");
    // put bundle
    [src prepareForSegue:segue sender:sender];
    printf("4");
    [segue perform];
    printf("7");
}


- (void) see {
    qwe("view = %s", ssString(self.view));
    //qwe("self.frame = %s", ssCGRect(self.view.frame));
    qwe("main = %s", ssString(self.main));
    //qwe("self.frame = %s", ssCGRect(self.safeArea.frame));
}

#pragma mark - testing
bool debug = 0 > 0;
- (void) test {
    // testing on compile filter
    //FLGPUImageLensFlareFilter* f = [FLGPUImageLensFlareFilter new];
    [self v1];
    FLGPUImageSimple2DFilter *f = [FLGPUImageSimple2DFilter new];
    FLGPUImageMaskFilter* f2 = [FLGPUImageMaskFilter new];
}

- (void) addStack {
    __kindof UIView *v;
    UIView * parent = self.main;
    if (v) {
        [v removeFromSuperview];
    }

    NSMutableArray * cons = [NSMutableArray new];
    UIStackView* a;
    a = [UIStackView new];
    //a = self.horiz;
    a.axis = UILayoutConstraintAxisVertical;
    //a.axis = UILayoutConstraintAxisHorizontal;
    //w2
    a.alignment = UIStackViewAlignmentCenter;
    //a.alignment = UIStackViewAlignmentLeading;
    //a.alignment = UIStackViewAlignmentTop;
    //a.alignment = UIStackViewAlignmentTrailing;
    //a.alignment = UIStackViewAlignmentBottom;
    //a.alignment = UIStackViewAlignmentFill; // make width/height same
    //w1
    //a.alignment = UIStackViewAlignmentFill;
    //w1
    //a.distribution = UIStackViewDistributionFillEqually;
    // w2
    a.distribution = UIStackViewDistributionEqualSpacing;
    a.spacing = 1;
    for (int i = 0; i < 5; i++) {
        UIView *x = [UIView new];
        x.layer.backgroundColor = FLUIKit.color12[i].CGColor;

        //
        //[cons add:[x.heightAnchor constraintEqualToConstant:20 + 10* i] ];

        //w2
        [cons add:[x.widthAnchor constraintEqualToConstant:20 + 10* i] ];
        //w2
        [cons add:[x.heightAnchor constraintEqualToConstant:20 + 10* i] ];

        //[cons add: [FLLayouts view:x align:NSLayoutAttributeWidth to:a ] ];
        //[cons add: [FLLayouts view:x set:NSLayoutAttributeHeight to:20] ];
        //[cons add: [FLLayouts view:x set:NSLayoutAttributeWidth to:20] ];

        //[a addSubview:x];

        // w1, w2
        [a addArrangedSubview:x];
    }
    //w2
    [FLLayouts applyConstraints:cons];

    //[FLLayouts activate:a forConstraint:cons];
    a.backgroundColor = UIColor.brownColor; // ios12.4 = x
    //a.layer.backgroundColor = UIColor.brownColor.CGColor; // ios 12.4 = x, ios14.3 = o
    v = a;
    CGRect r = parent.frame;
    double h = 70;
    CGRect f = CGRectMake(0, 200, 200, 250);
    if (debug) {
        f = CGRectMake(0, 200, 300, 70);
    }
    v.frame = f;
    [parent addSubview:v];
    qw("view as %s", ssString(v));
}

#pragma mark - Test
// Listing all bundles
- (void) testBundle {
    NSArray<NSBundle*>* all;
    all = NSBundle.allBundles;
    qwe("Here is %s", "all bundles");
    [all printAll];
    all = NSBundle.allFrameworks;
    qwe("Here is %s", "all framework");
    [all printAll];
    NSBundle* m = NSBundle.mainBundle;
    NSArray * a = @[
        m.bundlePath, m.bundleURL, m.bundleIdentifier,
        m.resourcePath, m.resourceURL,
        m.executablePath, m.executableURL,
        m.builtInPlugInsPath, m.builtInPlugInsURL,
        m.infoDictionary, m.localizedInfoDictionary,
    ];

    // #   0 : /private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app
    // #   1 : file:///private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app/
    // #   2 : com.cyberlink.photodirector
    // #   3 : /private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app
    // #   4 : file:///private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app/
    // #   5 : /private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app/photodirector
    // #   6 : file:///private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app/photodirector
    // #   7 : /private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app/PlugIns
    // #   8 : PlugIns/ -- file:///private/var/containers/Bundle/Application/726A8194-4355-43AB-98DB-FCD03A635EC8/photodirector.app/
    qwe("Here is %s", "main bundle");
    [a printAll];
}

- (void) v1 {
    NSArray* a;
    UIView *p = self.view;
    p = self.main;

    //SurrealArtTopBar *sa = [SurrealArtTopBar new];
    SurrealArtEraserPanel *sa = [SurrealArtEraserPanel new];
    [p addSubview:sa];
    a = @[
            [FLLayouts view:sa drawer:FLSideBottom to:p depth:80],
    ];
    [FLLayouts activate:p forConstraint:a];
    //--

    SurrealArtEraserTopBar *sa1 = [SurrealArtEraserTopBar new];
    //SurrealArtAdjust1 *sa1 = [SurrealArtAdjust1 new];
    [p addSubview:sa1];
    a = @[
            [FLLayouts view:sa1 above:sa],
            [FLLayouts view:sa1 sameXTo:p],
            [FLLayouts view:sa1 set:NSLayoutAttributeHeight to:50],
            //[FLLayouts view:sa drawer:FLSideBottom to:p depth:80 offset:UIEdgeInsetsMake(0, 0, 80, 0)],
    ];
    [FLLayouts activate:p forConstraint:a];
    //--

    SurrealArtItemsArea *si = [SurrealArtItemsArea new];
    [p addSubview:si];
    a = @[
            [FLLayouts view:si width:200 height:100],
            [FLLayouts view:si above:sa1],
            [FLLayouts view:si align:NSLayoutAttributeLeft to:sa1],
    ];
    [FLLayouts activate:p forConstraint:a];
}

@end


#pragma clang diagnostic pop
