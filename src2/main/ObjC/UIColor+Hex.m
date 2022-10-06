//
//  UIColor+Hex.m
//  PhotoDirector
//
//  Created by Eric Chen on 2019/6/3.
//  Copyright © 2019 CyberLink. All rights reserved.
//

#import "UIColor+Hex.h"

int toInt2(char c, char d);
int toInt(char c);
char toHex(int x);

@implementation UIColor (Hex)

+ (UIColor*) colorWithHex: (NSString*)hex {
    const long n = hex.length;
    const char *s = hex.UTF8String;
    bool rgb = n == 4; // #rgb
    bool argb = n == 5; // #argb
    bool rrggbb = n == 7; // #rrggbb
    bool aarrggbb = n == 9; // #aarrggbb
    bool valid = rgb || argb || rrggbb || aarrggbb;
    bool ok = s[0] == '#' && valid;
    int a = 0, r = 0, g = 0, b = 0;
    if (!ok) {
        NSLog(@"Unknown color syntax : %@ (Valid = #rgb, #argb, #rrggbb, #aarrggbb)", hex);
        return UIColor.clearColor;
    }

    // Parsing color by each syntax
    if (rgb) {
        a = 255;
        r = toInt2(s[1], s[1]);
        g = toInt2(s[2], s[2]);
        b = toInt2(s[3], s[3]);
    } else if (argb) {
        a = toInt2(s[1], s[1]);
        r = toInt2(s[2], s[2]);
        g = toInt2(s[3], s[3]);
        b = toInt2(s[4], s[4]);
    } else if (rrggbb) {
        a = 255;
        r = toInt2(s[1], s[2]);
        g = toInt2(s[3], s[4]);
        b = toInt2(s[5], s[6]);
    } else if (aarrggbb) {
        a = toInt2(s[1], s[2]);
        r = toInt2(s[3], s[4]);
        g = toInt2(s[5], s[6]);
        b = toInt2(s[7], s[8]);
    }
    return [self colorArgb:a r:r g:g b:b];
}

+ (UIColor*) colorWithInt: (long)argb {
    int cs[4] = {0};
    for (int i = 0; i < 4; i++) {
        int sh = 8 * (3 - i);
        cs[i] = (int) ((argb >> sh) & 0xFF);
    }
    return [UIColor colorArgb:cs[0] r:cs[1] g:cs[2] b:cs[3]];
}

+ (UIColor*) colorArgb: (int)a r:(int)r g:(int)g b:(int)b {
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a / 255.0];
}

- (NSString *)hex {
    int c = [self colorInt];
    return [NSString stringWithFormat:@"#%X", c];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
//[-Wunused-variable]
- (int) colorInt {
    double argb[4] = {0};
    bool ok = [self getRed:&argb[1] green:&argb[2] blue:&argb[3] alpha:&argb[0]];
    int ans = 0;
    for (int i = 0; i < 4; i++) {
        int x = (int) round(argb[i] * 255);
        ans |= (0xFF & x) << (24 - i*8);
    }
    return ans;
}
#pragma clang diagnostic pop

int toInt2(char c, char d) {
    return (toInt(c) << 4) | toInt(d);
}

int toInt(char c) {
    if (isxdigit(c)) { // 0-9, a-f, A-F
        int p = isalpha(c);  // a/A ? 0
        if (p) {
            int a = isupper(c) ? 'A' : 'a'; // A ? a
            return 10 + c - a;
        } else {
            return c - '0';
        }
    }
    return 0;
}

char toHex(int x) {
    if (0 <= x && x <= 15) {
        if (x < 10) {
            return (char) ('0' + x);
        } else {
            return (char) ('A' + x - 10);
        }
    }
    return '?';
}

@end
