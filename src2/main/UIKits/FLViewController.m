//
// Created by Eric Chen on 2020/12/22.
// Copyright (c) 2020 CyberLink. All rights reserved.
//

#import <photodirector-Swift.h>
#import "FLViewController.h"
#import "FLGPUImageLensFlareFilter.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wsign-conversion"
@implementation FLViewController {
    bool logLife;
}


#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    logLife = true;
    if (logLife) {
        qw("V %s", "Load");
    }
    [self setupClose];
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
    [self test];
    //[self.seek logChild];
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

- (void) setupClose {
    // Apply press color
    UIView *p = self.view;
    FLImageView *v = self.close;
    FLRes *c = [FLRes normal:@"#f00" disable:@"#ddd" pressed:@"#800" selected:@"#dd0"];
    [c applyBackgroundColorTo:v];
    NSArray* a = @[
            [FLLayouts view:v corner:FLCornerLeftTop to:p],
            [FLLayouts view:v width:50 height:50],
    ];
    [FLLayouts activate:v forConstraint:a];
}

#pragma mark - Listeners

- (IBAction)onClickClose:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)onSeekbarValue:(id)sender {
    qw("seek v = %.2f", self.seek.value);
    [self.seek logChild];
    [self.seek.constraints printAll];
}
- (IBAction)onClickPress:(id)sender {
    // Bring parameter of image

    FLStoryboardInfo* a1 = [FLStoryboardInfo new];
    FLStoryboardInfo* a2 = [FLStoryboardInfo presentFullScreen];
    FLStoryboardInfo* args = a1;
    //[LightHitViewController presentMeWithSrc:self args:args];
    [FLSViewController presentMeWithSrc:self args:args];
}

//+ (UIButton*)addEntry:(__kindof UIViewController*)parent {
+ (FLImageView*)addEntry:(__kindof UIViewController*)parent {
    FLImageView *add = [FLImageView new];
    [FLRes applyAllTitle:@"Test UI" to:add];
    add.frame = CGRectMake(0, 50, 80, 80);
    FLRes *c = [FLRes normal:@"#800" disable:@"#888" pressed:@"#400" selected:@"880"];
    add.BGColors = c;
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
    NSString* id = @"FLStoryboard";
    // value is in Storyboard, select ViewController, CustomClass = /className/, Storyboard Id = /vcId/
    NSString *vcId = @"FLViewController";
    NSString *sid = [id addF:@"_segue"];
    //2021-01-12 17:35:20.582282+0800 photodirector[9329:1655935] global exception:Storyboard (<UIStoryboard: 0x2808d2f80>) doesn't contain a view controller with identifier 'FLStoryboard'
    UIStoryboard *board = [UIStoryboard storyboardWithName:id bundle:nil];
    //printf("1");
    FLViewController *vc = [board instantiateViewControllerWithIdentifier:vcId];
    //printf("2");

    UIStoryboardSegue* segue = [UIStoryboardSegue segueWithIdentifier:sid source:src destination:vc performHandler:^{
        //printf("5");
        // View did load
        [src presentViewController:vc animated:NO completion:nil];
        //printf("6");
    }];
    //printf("3");
    // put bundle
    [src prepareForSegue:segue sender:sender];
    //printf("4");
    [segue perform];
    //printf("7");
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
    FLGPUImageLensFlareFilter* f = [FLGPUImageLensFlareFilter new];
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
//
//FLLibrary *lib;
//-(void) addLib {
//    __kindof UIView *v = lib;
//    UIView* parent = self.main;
//    if (v) {
//        [v removeFromSuperview];
//    }
//    FLLibrary* lib = [FLLibrary new];
//
//    UICollectionViewFlowLayout* flow = [UICollectionViewFlowLayout new];
//    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    flow.minimumLineSpacing = 0;
//    flow.minimumInteritemSpacing = 0;
//    //lib = (FLLibrary *) [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
//    //[lib setup];
//    //lib = UICollectionView(frame: .zero, collectionViewLayout: flow)
//    v = lib;
//    CGRect r = parent.frame;
//    double h = 200;
//    CGRect f = CGRectMake(0, 250, r.size.width, h);
//    if (debug) {
//        f = CGRectMake(200, 200, h, h);
//    }
//    v.frame = f;
//    [parent addSubview:v];
//    qw("view as %s", ssString(v));
//}

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

- (void) testInit {
    CGRect f = CGRectMake(0, 0, 50, 50);
    FLImageView *v;
    qwe("by %s", "new");
    v = [FLImageView new];
    v.frame = CGRectOffset(f, 5, 5);

    qwe("by %s", "alloc init");
    v = [[FLImageView alloc] init];
    v.frame = CGRectOffset(f, 15, 15);

    qwe("by %s", "alloc initWithFrame");
    v = [[FLImageView alloc] initWithFrame:f];
    v.frame = CGRectOffset(f, 25, 25);
}

@end


#pragma clang diagnostic pop
