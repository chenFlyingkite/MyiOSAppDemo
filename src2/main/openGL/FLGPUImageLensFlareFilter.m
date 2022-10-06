#import "FLGPUImageLensFlareFilter.h"
#import "FLUtil.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-int-conversion"
NSString *const kGPUImageLensFlareVertexShaderString2 = SHADER_STRING
(
 //#version 300 es // fails
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;

 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;

 void main() {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
 }
);

NSString *const kGPUImageLensFlareFragmentShaderString2 = SHADER_STRING
(
 //#version 300 es // fails
 precision mediump float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;

 // Parameters
 uniform float alpha;
 uniform float scale;
 uniform float centerX;
 uniform float centerY;
 uniform float sinDegree;
 uniform float cosDegree;
 uniform float stickerWidth;
 uniform float stickerHeight;
 uniform float desktopWidth;
 uniform float desktopHeight;
 uniform int flip;

 vec4 getColor(vec4, vec4);

 // Utility methods
 int isIn(float v, float min, float max) {
     return (min <= v && v <= max) ? 1 : 0;
 }

// int hasFlag(int state, int flag) {
//     return (state & flag) == flag; // compile fails
// }

 int isIn0101(vec2 p) {
     int inX = isIn(p.x, 0.0, 1.0);
     int inY = isIn(p.y, 0.0, 1.0);
     return inX * inY;
 }

 // Main
 void main() {
     vec4 desktop = texture2D(inputImageTexture, textureCoordinate);
     vec4 stickerSrc = texture2D(inputImageTexture2, textureCoordinate2);

     if (scale <= 0.0 || stickerWidth <= 0.0 || stickerHeight <= 0.0) {
         gl_FragColor = desktop;
         return;
     }
     // DW = desktopWidth  , mW = stickerWidth  , cx = centerX of sticker
     // DH = desktopHeight , mH = stickerHeight , cy = centerY of sticker
     // (x, y) = (0 ~ 1) in Sticker
     // Let imageCoord be the screen ( so imageCoord.x = [0, DW], imageCoord.y = [0, DH])
     // gl_FragCoord.x = imageCoord.x / DW
     // gl_FragCoord.y = imageCoord.y / DH
     // we have
     // imageCoord.x = [fx] = [cx * DW] + [cos(d), -sin(d)] * s * [mW] * ([x] - [1/2])
     // imageCoord.y   [fy]   [cy * DH]   [sin(d),  cos(d)]       [mH]   ([y]   [1/2])
     // gl_FragCoord.x = x/DW = cx + s * mW / DW * (x - 1/2)
     // gl_FragCoord.y = y/DH = cy + s * mH / DH * (y - 1/2)
     //
     // for fx = cx * DW + s * mW * (x - 1/2)  (fx = [0, DW])
     // for fy = cy * DH + s * mW * (y - 1/2)  (fy = [0, DH])
     // => x = [1/2] + 1/s * [ cos(d), sin(d)] * ([fx] - [cx * mW * DW])
     // => y = [1/2]         [-sin(d), cos(d)]   ([fy] - [cy * mH * DH])
     float imageWidth = scale * stickerWidth;
     float imageHeight = scale * stickerHeight;

     // f.xy = fragment's x, y, range = 0~ DW/DH
     float fx = textureCoordinate2.x;
     float fy = textureCoordinate2.y;

     // this lines did not draw
     //fx = gl_FragCoord.x;
     //fy = gl_FragCoord.y;

     float xInDesktop = (fx - centerX) * desktopWidth;
     float yInDesktop = (fy - centerY) * desktopHeight;

     // rotate degree back as xInSticker
     vec2 inSticker;
     inSticker.x = (+cosDegree * xInDesktop + sinDegree * yInDesktop) / imageWidth + 0.5;
     inSticker.y = (-sinDegree * xInDesktop + cosDegree * yInDesktop) / imageHeight + 0.5;
     // flip coordinate
     if (flip == 1 || flip == 3) {
         inSticker.x = 1.0 - inSticker.x;
     }
     if (flip == 2 || flip == 3) {
         inSticker.y = 1.0 - inSticker.y;
     }

     vec4 ans;
     if (isIn0101(inSticker) > 0) {
         vec4 sticker = texture2D(inputImageTexture2, inSticker);
         ans = getColor(desktop, sticker);
     } else {
         ans = desktop;
     }
     gl_FragColor = ans;
 }
);

NSString *const kGPUImageLensFlareScreenShaderString2 = SHADER_STRING
(
     vec4 getColor(vec4 source4, vec4 light4) {
         vec3 light = light4.rgb;
         vec3 source = source4.rgb;

         vec3 blend = vec3(1.0) - (vec3(1.0) - source) * (vec3(1.0) - light);
         return vec4(mix(source, blend, light4.a * alpha), 1.0);
     }
);


//        precision mediump float;
//
//        varying vec2 textureCoordinate;
//        varying vec2 lens_flare_texture_coordinate;
//        uniform sampler2D inputImageTexture;
//        uniform sampler2D lens_flare_texture;
//
//        uniform float center_x;
//        uniform float center_y;
//        uniform float background_image_width;
//        uniform float background_image_height;
//        uniform float flare_width;
//        uniform float flare_height;
//        uniform float cos_rotate;
//        uniform float sin_rotate;
//        uniform float strength;
//        uniform int is_lens_flare;
//
//        void main()
//        {
//            vec3 source = texture2D(inputImageTexture, textureCoordinate).rgb;
//            if (is_lens_flare == 0)
//            {
//                gl_FragColor = vec4(source, 1.0);
//                return;
//            }
//
//            float coord_x = (lens_flare_texture_coordinate.x - center_x) * background_image_width;
//            float coord_y = (lens_flare_texture_coordinate.y - center_y) * background_image_height;
//
//            vec2 rotate_coordinate;
//            rotate_coordinate.x = (coord_x * cos_rotate + coord_y * sin_rotate) / flare_width + 0.5;
//            rotate_coordinate.y = (coord_y * cos_rotate - coord_x * sin_rotate) / flare_height + 0.5;
//
//            if (rotate_coordinate.x < 0.0 || rotate_coordinate.x > 1.0 || rotate_coordinate.y < 0.0 || rotate_coordinate.y > 1.0)
//            {
//                gl_FragColor = vec4(source, 1.0);
//            }
//            else
//            {
//);

/*
//----
NSString *const kGPUImageLensFlareVertexShaderString = SHADER_STRING
(
  attribute vec4 position; 
  attribute vec4 inputTextureCoordinate; 
  attribute vec4 input_lens_flare_texture_coordinate; 
   
  varying vec2 textureCoordinate; 
  varying vec2 lens_flare_texture_coordinate; 
   
  void main() 
  { 
      gl_Position = position; 
      textureCoordinate = inputTextureCoordinate.xy; 
      lens_flare_texture_coordinate = input_lens_flare_texture_coordinate.xy; 
  } 
);

NSString *const kGPUImageLensFlareFragmentShaderString = SHADER_STRING
(
  precision mediump float; 
   
  varying vec2 textureCoordinate; 
  varying vec2 lens_flare_texture_coordinate; 
  uniform sampler2D inputImageTexture; 
  uniform sampler2D lens_flare_texture; 
   
  uniform float center_x; 
  uniform float center_y; 
  uniform float background_image_width; 
  uniform float background_image_height; 
  uniform float flare_width; 
  uniform float flare_height; 
  uniform float cos_rotate; 
  uniform float sin_rotate; 
  uniform float strength; 
  uniform int is_lens_flare; 
   
  void main() 
  { 
       vec3 source = texture2D(inputImageTexture, textureCoordinate).rgb; 
       if (is_lens_flare == 0) 
       { 
           gl_FragColor = vec4(source, 1.0); 
           return; 
       } 
        
       float coord_x = (lens_flare_texture_coordinate.x - center_x) * background_image_width; 
       float coord_y = (lens_flare_texture_coordinate.y - center_y) * background_image_height; 
   
       vec2 rotate_coordinate; 
       rotate_coordinate.x = (coord_x * cos_rotate + coord_y * sin_rotate) / flare_width + 0.5; 
       rotate_coordinate.y = (coord_y * cos_rotate - coord_x * sin_rotate) / flare_height + 0.5; 
   
       if (rotate_coordinate.x < 0.0 || rotate_coordinate.x > 1.0 || rotate_coordinate.y < 0.0 || rotate_coordinate.y > 1.0) 
       { 
           gl_FragColor = vec4(source, 1.0); 
       } 
       else 
       { 
);

//###############################
//###############################

NSString *const kGPUImageLensFlareScreenShaderString2 = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb; 
           vec3 blend = vec3(1.0) - (vec3(1.0) - source) * (vec3(1.0) - light); 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength; 
           vec3 color = mix(source, blend, weight); 
           gl_FragColor = vec4(color, 1.0); 
       } 
  } 
);

NSString *const kGPUImageLensFlareMultiplyShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb; 
           vec3 blend = source * light; 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength; 
           vec3 color = mix(source, blend, weight); 
           gl_FragColor = vec4(color, 1.0); 
       } 
  } 
);
 
NSString *const kGPUImageLensFlareNormalShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb; 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength; 
           vec3 color = mix(source, light, weight); 
           gl_FragColor = vec4(color, 1.0); 
       } 
  } 
);

 
NSString *const kGPUImageLensFlareHardlightShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb; 
           vec3 multiply = vec3(2.0) * source * light; 
           vec3 screen = vec3(1.0) - vec3(2.0) * (vec3(1.0) - source) * (vec3(1.0) - light); 
           vec3 step_result = step(vec3(0.5), light); 
           vec3 blend = (vec3(1.0) - step_result) * multiply + step_result * screen; 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength; 
           vec3 color = mix(source, blend, weight); 
           gl_FragColor = vec4(color, 1.0); 
       } 
  } 
);
 
NSString *const kGPUImageLensFlareSoftlightShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb; 
           vec3 result_1 = vec3(2.0) * source * light + source * source * (vec3(1.0) - vec3(2.0) * light); 
           vec3 result_2 = vec3(2.0) * source * (vec3(1.0) - light) + sqrt(source) * (vec3(2.0) * light - vec3(1.0)); 
           vec3 step_result = step(vec3(0.5), light); 
           vec3 blend = (vec3(1.0) - step_result) * result_1 + step_result * result_2; 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength; 
           vec3 color = mix(source, blend, weight); 
           gl_FragColor = vec4(color, 1.0); 
       } 
  } 
);

NSString *const kGPUImageLensFlareOverlayShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb; 
           vec3 multiply = vec3(2.0) * source * light; 
           vec3 screen = vec3(1.0) - vec3(2.0) * (vec3(1.0) - source) * (vec3(1.0) - light); 
           vec3 step_result = step(vec3(0.5), source); 
           vec3 blend = (vec3(1.0) - step_result) * multiply + step_result * screen; 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength; 
           vec3 color = mix(source, blend, weight); 
           gl_FragColor = vec4(color, 1.0); 
       } 
  } 
);

NSString *const kGPUImageLensFlareLightenShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = max(source, light);
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareDarkenShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = min(source, light);
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareDifferenceShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = abs(source - light);
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareHueShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           float fMax = max(max(light.r, light.g), light.b);
           float fMin = min(min(light.r, light.g), light.b);
           float fChromaSrc = fMax - fMin;

           float fHueSrc = 0.0;
           if(fChromaSrc > 0.001)
           {
             if(fMax == light.r)
                 fHueSrc = mod((((light.g - light.b) /  fChromaSrc) + 6.0), 6.0);
             else if(fMax == light.g)
                 fHueSrc = ((light.b - light.r) /  fChromaSrc) + 2.0;
             else
                 fHueSrc = ((light.r - light.g) /  fChromaSrc) + 4.0;
           }

           fMax = max(max(source.r, source.g), source.b);
           fMin = min(min(source.r, source.g), source.b);
           float fChromaBackdrop = fMax - fMin;
           float fLuminanceBackdrop = dot(source, vec3(0.299, 0.587, 0.114));

           vec3 HCL = vec3(fHueSrc, fChromaBackdrop, fLuminanceBackdrop);
           if(fChromaSrc < 0.001)
             HCL.g = fChromaSrc;

           vec3 blend;
           if(HCL.g < 0.001)
             blend = vec3(HCL.b, HCL.b, HCL.b);
           else
           {
             float fX = HCL.g * (1.0 - abs(mod(HCL.r, 2.0) - 1.0));
             if(HCL.r < 1.0)
                 blend = vec3(HCL.g, fX, 0.0);
             else if(HCL.r < 2.0)
                 blend = vec3(fX, HCL.g, 0.0);
             else if(HCL.r < 3.0)
                 blend = vec3(0.0, HCL.g, fX);
             else if(HCL.r < 4.0)
                 blend = vec3(0.0, fX, HCL.g);
             else if(HCL.r < 5.0)
                 blend = vec3(fX, 0.0, HCL.g);
             else
                 blend = vec3(HCL.g, 0.0, fX);

             float fm = HCL.b - dot(blend, vec3(0.299, 0.587, 0.114));
             blend += vec3(fm, fm, fm);
             blend = max(vec3(0.0), min(vec3(1.0), blend));
           }

           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareColorShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           float fMax = max(max(light.r, light.g), light.b);
           float fMin = min(min(light.r, light.g), light.b);
           float fChromaSrc = fMax - fMin;

           float fHueSrc = 0.0;
           if(fChromaSrc > 0.001)
           {
             if(fMax == light.r)
                 fHueSrc = mod((((light.g - light.b) /  fChromaSrc) + 6.0), 6.0);
             else if(fMax == light.g)
                 fHueSrc = ((light.b - light.r) /  fChromaSrc) + 2.0;
             else
                 fHueSrc = ((light.r - light.g) /  fChromaSrc) + 4.0;
           }

           float fLuminanceBackdrop = dot(source, vec3(0.299, 0.587, 0.114));

           vec3 HCL = vec3(fHueSrc, fChromaSrc, fLuminanceBackdrop);
           if(fChromaSrc < 0.001)
             HCL.g = fChromaSrc;

           vec3 blend;
           if(HCL.g < 0.001)
             blend = vec3(HCL.b, HCL.b, HCL.b);
           else
           {
             float fX = HCL.g * (1.0 - abs(mod(HCL.r, 2.0) - 1.0));
             if(HCL.r < 1.0)
                 blend = vec3(HCL.g, fX, 0.0);
             else if(HCL.r < 2.0)
                 blend = vec3(fX, HCL.g, 0.0);
             else if(HCL.r < 3.0)
                 blend = vec3(0.0, HCL.g, fX);
             else if(HCL.r < 4.0)
                 blend = vec3(0.0, fX, HCL.g);
             else if(HCL.r < 5.0)
                 blend = vec3(fX, 0.0, HCL.g);
             else
                 blend = vec3(HCL.g, 0.0, fX);

             float fm = HCL.b - dot(blend, vec3(0.299, 0.587, 0.114));
             blend += vec3(fm, fm, fm);
             blend = max(vec3(0.0), min(vec3(1.0), blend));
           }
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareLuminosityShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           float fLuminanceSrc = dot(light, vec3(0.299, 0.587, 0.114));
           float fMax = max(max(source.r, source.g), source.b);
           float fMin = min(min(source.r, source.g), source.b);
           float fChromaBackdrop = fMax - fMin;

           float fHueBackdrop = 0.0;
           if(fChromaBackdrop > 0.001)
           {
             if(fMax == source.r)
                 fHueBackdrop = mod((((source.g - source.b) /  fChromaBackdrop) + 6.0), 6.0);
             else if(fMax == source.g)
                 fHueBackdrop = ((source.b - source.r) /  fChromaBackdrop) + 2.0;
             else
                 fHueBackdrop = ((source.r - source.g) /  fChromaBackdrop) + 4.0;
           }

           vec3 HCL = vec3(fHueBackdrop, fChromaBackdrop, fLuminanceSrc);

           vec3 blend;
           if(HCL.g < 0.001)
             blend = vec3(HCL.b, HCL.b, HCL.b);
           else
           {
             float fX = HCL.g * (1.0 - abs(mod(HCL.r, 2.0) - 1.0));
             if(HCL.r < 1.0)
                 blend = vec3(HCL.g, fX, 0.0);
             else if(HCL.r < 2.0)
                 blend = vec3(fX, HCL.g, 0.0);
             else if(HCL.r < 3.0)
                 blend = vec3(0.0, HCL.g, fX);
             else if(HCL.r < 4.0)
                 blend = vec3(0.0, fX, HCL.g);
             else if(HCL.r < 5.0)
                 blend = vec3(fX, 0.0, HCL.g);
             else
                 blend = vec3(HCL.g, 0.0, fX);

             float fm = HCL.b - dot(blend, vec3(0.299, 0.587, 0.114));
             blend += vec3(fm, fm, fm);
             blend = max(vec3(0.0), min(vec3(1.0), blend));
           }
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareSaturationShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           float fMax = max(max(light.r, light.g), light.b);
           float fMin = min(min(light.r, light.g), light.b);
           float fChromaSrc = fMax - fMin;

           float fLuminanceBackdrop = dot(source, vec3(0.299, 0.587, 0.114));
           fMax = max(max(source.r, source.g), source.b);
           fMin = min(min(source.r, source.g), source.b);
           float fChromaBackdrop = fMax - fMin;

           float fHueBackdrop = 0.0;
           if(fChromaBackdrop > 0.001)
           {
             if(fMax == source.r)
                 fHueBackdrop = mod((((source.g - source.b) /  fChromaBackdrop) + 6.0), 6.0);
             else if(fMax == source.g)
                 fHueBackdrop = ((source.b - source.r) /  fChromaBackdrop) + 2.0;
             else
                 fHueBackdrop = ((source.r - source.g) /  fChromaBackdrop) + 4.0;
           }

           if(fChromaBackdrop < 0.0196)
             fChromaSrc = fChromaSrc * fChromaBackdrop / 0.0196;
           if(fLuminanceBackdrop > 0.70588)
             fChromaSrc = fChromaSrc * (1.0 - fLuminanceBackdrop) / 0.29411;
           if(fLuminanceBackdrop < 0.23529)
             fChromaSrc = fChromaSrc * fLuminanceBackdrop / 0.23529;

           vec3 HCL = vec3(fHueBackdrop, fChromaSrc, fLuminanceBackdrop);

           vec3 blend;
           if(HCL.g < 0.001)
             blend = vec3(HCL.b, HCL.b, HCL.b);
           else
           {
             float fX = HCL.g * (1.0 - abs(mod(HCL.r, 2.0) - 1.0));
             if(HCL.r < 1.0)
                 blend = vec3(HCL.g, fX, 0.0);
             else if(HCL.r < 2.0)
                 blend = vec3(fX, HCL.g, 0.0);
             else if(HCL.r < 3.0)
                 blend = vec3(0.0, HCL.g, fX);
             else if(HCL.r < 4.0)
                 blend = vec3(0.0, fX, HCL.g);
             else if(HCL.r < 5.0)
                 blend = vec3(fX, 0.0, HCL.g);
             else
                 blend = vec3(HCL.g, 0.0, fX);

             float fm = HCL.b - dot(blend, vec3(0.299, 0.587, 0.114));
             blend += vec3(fm, fm, fm);
             blend = max(vec3(0.0), min(vec3(1.0), blend));
           }

           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareVividlightShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blendMax = min(vec3(1.0), source / ((vec3(1.0) - light) * 2.0));
           vec3 blend = max(vec3(0.0), vec3(1.0) - (vec3(1.0) - source) / (light * 2.0));

           bvec3 bGreater = greaterThan(light, vec3(0.5));
           blend = blendMax * vec3(bGreater) + blend * vec3(not(bGreater));

           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareSubtractShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = max(vec3(0.0), source - light);
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlarePinlightShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blendMax = max(source, light * 2.0 - vec3(1.0));
           vec3 blend = min(source, light * 2.0);
           bvec3 bGreater = greaterThan(light, vec3(0.5));
           blend = blendMax * vec3(bGreater) + blend * vec3(not(bGreater));
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareLinearlightShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = max(vec3(0.0), min(vec3(1.0), source + (light * 2.0) - vec3(1.0)));
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareLineardodgeShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = min(vec3(1.0), light + source);
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);


NSString *const kGPUImageLensFlareLinearburnShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = max(vec3(0.0), light + source - vec3(1.0));
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareLightercolorShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           float fLuminanceLight = dot(light, vec3(0.299, 0.587, 0.114));
           float fLuminanceEffect = dot(source, vec3(0.299, 0.587, 0.114));
           vec3 blend;
           if(fLuminanceLight < fLuminanceEffect)
             blend = source;
           else
             blend = light;
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareHardmixShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = step(1.0, light + source);
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareExclusionShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = light + source - (light * source * 2.0);
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareDivideShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = min(vec3(1.0), source / max(vec3(0.001), light));
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareDarkercolorShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           float fLuminanceLight = dot(light, vec3(0.299, 0.587, 0.114));
           float fLuminanceEffect = dot(source, vec3(0.299, 0.587, 0.114));
           vec3 blend;
           if(fLuminanceLight < fLuminanceEffect)
             blend = light;
           else
             blend = source;
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareColordodgeShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = min(vec3(1.0), source / max(vec3(0.001), vec3(1.0) - light));
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);

NSString *const kGPUImageLensFlareColorburnShaderString = SHADER_STRING
(
           vec3 light = texture2D(lens_flare_texture, rotate_coordinate).rgb;
           vec3 blend = max(vec3(0.0), vec3(1.0) - (vec3(1.0) - source) / max(light, vec3(0.001)));
 
           float weight = texture2D(lens_flare_texture, rotate_coordinate).a * strength;
           vec3 color = mix(source, blend, weight);
           gl_FragColor = vec4(color, 1.0);
       }
  }
);
*/

@interface FLGPUImageLensFlareFilter() {}

@end

@implementation FLGPUImageLensFlareFilter {
    bool log;
    FLTicTac *clk;
}


#pragma mark -
#pragma mark Initialization and teardown

- (NSString*) getFragmentProgram {
    NSString* fragment = kGPUImageLensFlareFragmentShaderString2;
    fragment = [fragment add:kGPUImageLensFlareScreenShaderString2];
    return fragment;
}

- (instancetype) init {
    clk = [FLTicTac new];
    log = true;
    clk.enable = log;
    NSString *vertex;
    NSString *fragment;
    vertex = kGPUImageLensFlareVertexShaderString2;
    //fragment = kGPUImageLensFlareFragmentShaderString2;
    fragment = [self getFragmentProgram];
    //self = [super initWithVertexShaderFromString:vertex fragmentShaderFromString:fragment];
    qwe("vertex   = %s", ssString(vertex));
    qwe("fragment = %s", ssString(fragment));
    self = [super initWithFragmentShaderFromString:fragment];
    if (!self) {
        return nil;
    }

    [self setDefaultValues];
    return self;
}

- (void) setDefaultValues {
    self.stickerAlpha = 1;
    self.stickerScale = 1;
    self.stickerDegree = 0;
    self.stickerCenterX = 0.5;
    self.stickerCenterY = 0.5;
    self.stickerFlip = 0;
    [self setStickerWidth:0 height:0];
}


/*
- (id)initWithImage:(UIImage *)image blendingType:(LensFlareBlendTypes)blendingType;
{
    NSString *fragment_shader = kGPUImageLensFlareFragmentShaderString;
    switch (blendingType)
    {
        case LENS_FLARE_NORMAL:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareNormalShaderString];
            break;
            
        case LENS_FLARE_SCREEN:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareScreenShaderString2];
            break;
            
        case LENS_FLARE_MULTIPLY:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareMultiplyShaderString];
            break;
            
        case LENS_FLARE_HARDLIGHT:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareHardlightShaderString];
            break;
            
        case LENS_FLARE_OVERLAY:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareOverlayShaderString];
            break;
            
        case LENS_FLARE_SOFTLIGHT:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareSoftlightShaderString];
            break;
            
        case LENS_FLARE_LIGHTEN:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareLightenShaderString];
            break;

        case LENS_FLARE_DARKEN:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareDarkenShaderString];
            break;

        case LENS_FLARE_DIFFERENCE:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareDifferenceShaderString];
            break;

        case LENS_FLARE_HUE:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareHueShaderString];
            break;

        case LENS_FLARE_COLOR:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareColorShaderString];
            break;

        case LENS_FLARE_LUMINOSITY:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareLuminosityShaderString];
            break;

        case LENS_FLARE_SATURATION:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareSaturationShaderString];
            break;

        case LENS_FLARE_VIVIDLIGHT:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareVividlightShaderString];
            break;

        case LENS_FLARE_SUBTRACT:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareSubtractShaderString];
            break;

        case LENS_FLARE_PINLIGHT:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlarePinlightShaderString];
            break;

        case LENS_FLARE_LINEARLIGHT:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareLinearlightShaderString];
            break;

        case LENS_FLARE_LINEARDODGE:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareLineardodgeShaderString];
            break;

        case LENS_FLARE_LINEARBURN:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareLinearburnShaderString];
            break;

        case LENS_FLARE_LIGHTERCOLOR:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareLightercolorShaderString];
            break;

        case LENS_FLARE_HARDMIX:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareHardmixShaderString];
            break;

        case LENS_FLARE_EXCLUSION:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareExclusionShaderString];
            break;

        case LENS_FLARE_DIVIDE:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareDivideShaderString];
            break;

        case LENS_FLARE_DARKERCOLOR:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareDarkercolorShaderString];
            break;

        case LENS_FLARE_COLORDODGE:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareColordodgeShaderString];
            break;

        case LENS_FLARE_COLORBURN:
            fragment_shader = [fragment_shader stringByAppendingString:kGPUImageLensFlareColorburnShaderString];
            break;

        default:
            NSLog(@"WARNING: No such blending type");
            return nil;
    }
    //-- Eric
    NSString * vertex;
    vertex = kGPUImageLensFlareVertexShaderString;
    vertex = kGPUImageLensFlareVertexShaderString2;
    fragment_shader = kGPUImageLensFlareFragmentShaderString2;
    //--
    
    if (!(self = [super initWithVertexShaderFromString:vertex fragmentShaderFromString:fragment_shader]))
    {
        return nil;
    }
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        m_lens_flare_texture_coordinate_attribute = [filterProgram attributeIndex:@"input_lens_flare_texture_coordinate"];
        glEnableVertexAttribArray(m_lens_flare_texture_coordinate_attribute);
    });
    
    m_lens_flare_texture_uniform = [filterProgram uniformIndex:@"lens_flare_texture"];
    centerX_uni = [filterProgram uniformIndex:@"center_x"];
    centerY_uniform = [filterProgram uniformIndex:@"center_y"];
    stickerWidth_uniform = [filterProgram uniformIndex:@"flare_width"];
    stickerHeight_uniform = [filterProgram uniformIndex:@"flare_height"];
    desktopWidth_uniform = [filterProgram uniformIndex:@"background_image_width"];
    desktopHeight_uniform = [filterProgram uniformIndex:@"background_image_height"];
    cosDegree_uniform = [filterProgram uniformIndex:@"cos_rotate"];
    sinDegree_uniform = [filterProgram uniformIndex:@"sin_rotate"];
    alpha_uniform = [filterProgram uniformIndex:@"strength"];
    m_is_lens_flare_uniform = [filterProgram uniformIndex:@"is_lens_flare"];
    
    m_lens_flare_framebuffer = nil;
    if (image != nil)
    {
        [self loadImageToTexture:image];
    }
    
    mCenterX = 0.1;
    mCenterY = 0.1;
    mDegree = 0.0;
    mScale = 1.0;
    mAlpha = 1.0;
    
    [self setCenterX:mCenterX Y:mCenterY];
    [self setRotation:mDegree];
    [self setScale:mScale];
    [self setBlendStrength:mAlpha];
    
    GLfloat lens_flare_texture_coordinate[8] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    m_lens_flare_texture_coordinate = (GLfloat*)malloc(8 * sizeof(GLfloat));
    memcpy(m_lens_flare_texture_coordinate, lens_flare_texture_coordinate, 8 * sizeof(GLfloat));
    
    return self;
}
*/

#pragma mark -
#pragma mark Managing rendering

- (void)setupFilterForSize:(CGSize)filterFrameSize {
    CGSize z = filterFrameSize;
    [self setDesktopWidth:z.width height:z.height];
    if (log) {
        qw("bg image = (%.2f, %.2f)", mDesktopWidth, mDesktopHeight);
        qwe("now = %s", ssString([FLStringKit now]));
    }
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    if (log) {
        qwe("setInputSize #%ld = %s", textureIndex, ssCGSize(newSize));
    }
    [super setInputSize:newSize atIndex:textureIndex];
    if (textureIndex == 1) {
        CGSize z = newSize;
        [self setStickerWidth:z.width height:z.height];
    }
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates {
    if (log) {
        [self logAll];
        qwe("start render %s", "");
    }
    [clk tic];
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates];
    [clk tac:@"now render ok = %s", ssString([FLStringKit now])];
    if (log) {
        qwe("render done %s", "");
    }
}

#pragma mark -
#pragma mark Accessors

- (void) logAll {
    qw("a =  %.2f,   deg = %.2f,   (cx, cy) = (%.3f, %.3f),   s = %.2f",
            mAlpha, mDegree, mCenterX, mCenterY, mScale);
    qw("desktop = (%7.2f, %7.2f), sticker = (%7.2f, %7.2f)", mDesktopWidth, mDesktopHeight, mStickerWidth, mStickerHeight);
}

- (void)setStickerAlpha:(float)alpha {
    mAlpha = (float) makeInBoundF(alpha, 0.0, 1.0);
    [self setFloat:mAlpha forUniformName:@"alpha"];
}

- (void)setStickerCenterX:(float)cx {
    mCenterX = cx;
    [self setFloat:mCenterX forUniformName:@"centerX"];
}

- (void)setStickerCenterY:(float)cy {
    mCenterY = cy;
    [self setFloat:mCenterY forUniformName:@"centerY"];
}

- (void)setStickerScale:(float)scale {
    mScale = scale;
    [self setFloat:mScale forUniformName:@"scale"];
}

- (void)setStickerDegree:(float)degree {
    mDegree = degree;
    double rad = degToRad(mDegree);
    float sind = (float) sin(rad);
    float cosd = (float) cos(rad);
    [self setFloat:sind forUniformName:@"sinDegree"];
    [self setFloat:cosd forUniformName:@"cosDegree"];
}

- (void)setStickerFlip:(int)flip {
    mStickerFlip = flip;
    [self setInteger:mStickerFlip forUniformName:@"flip"];
}

- (CGSize) getStickerSize {
    return CGSizeMake(mStickerWidth, mStickerHeight);
}

- (void) setStickerWidth:(float)width height:(float)height {
    mStickerWidth  = width;
    mStickerHeight = height;
    [self setFloat:mStickerWidth  forUniformName:@"stickerWidth"];
    [self setFloat:mStickerHeight forUniformName:@"stickerHeight"];
}

- (void) setDesktopWidth:(float)width height:(float)height {
    mDesktopWidth  = width;
    mDesktopHeight = height;
    [self setFloat:mDesktopWidth  forUniformName:@"desktopWidth"];
    [self setFloat:mDesktopHeight forUniformName:@"desktopHeight"];
}
 
@end

#pragma clang diagnostic pop
