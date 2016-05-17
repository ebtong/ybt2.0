//
//  Global_h
//  0元夺宝
//
//
//  Copyright © 2016年 duobao. All rights reserved.
//
#import "ApiUri.h"

#ifndef Ebt_Global_h
#define Ebt_Global_h

#define SUCCESS_CODE @1
#define UNLOGIN_CODE @2
#define FAILURE_CODE @400
#define CODE_STRING @"code"

#define HGfont(s)  [UIFont systemFontOfSize:(s)]
#define HGColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define HGolorAlpha(r,g,b,alp) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(alp)]

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define NORMAL_LABEL_COLOR HGolorAlpha(51,51,51,1)
#define GREEN_LABEL_COLOR HGolorAlpha(31,189,166,1)
#define GREEN_BG_COLOR HGolorAlpha(214,246,242,1)
#define ORANGE_LABEL_COLOR HGolorAlpha(255,153,43,1)
#define ORANGE_BG_COLOR HGolorAlpha(255,237,217,1)
#define CELL_BG_COLOR HGolorAlpha(249,249,249,1)
#define TABLE_BG_COLOR HGolorAlpha(235,235,235,1)
#define GREY_LABEL_COLOR HGolorAlpha(153,153,153,1)
#define RED_BTN_COLOR HGolorAlpha(254,91,95,1)
#define BLUE_LABEL_COLOR HGolorAlpha(100,160,255,1)

/*爱贝云*/
//商户在爱贝注册的应用ID
#define mOrderUtilsAppId @"300519035"
//渠道号
#define mOrderUtilsChannel @"508821"
//支付结果后台回调地址
#define mOrderUtilsNotifyurl @"http://m.ybt999.com/?/ios_api/order/lapppayNotifyurl"
//商户验签公钥
#define mOrderUtilsCheckResultKey @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCHbRnWzTHfy4E4AssBma09FT6JxDnx1ETwY+C0UYX3zGxWjPXVGZM/PMORN9kjq9qQMwk7qOxOfdI9yNurWeQmni4Gws6cNW1cfVrGSsjHGhdr/xDu3QmFhZ/Jq2HKd5F0rrwGSx7zMuAszoPso/bL5SS0EKzYvxhWY7jVNMzisQIDAQAB"
//商户在爱贝注册的应用ID对应的应用私钥
#define mOrderUtilsCpPrivateKey @"MIICWwIBAAKBgQCEDsH2poEFETjAXKPyqzxRlPJAH193pbedOQXOdKd008Tup/DeXdm/1KlUE37y/N4QB22jNMdAkWK4LovjSTmLJ12VC1i+tY7N5g/Qot8iH5jUlNZ47+/mbna8xFeSZzvomB/NZ5snxhfxa4+MVPON9sVJxTYFjOAj0RkKfBwD2wIDAQABAoGAUifsO8qykbh5GhOIW7x0Njz3yTS7a/BJHyMOnbatR11IM0F/9JdmlJV1Er1eSUVP0aENcG+xVlYcmIE8vhYcGbOHzA0z8jONNdKa8c5i/sBS6HW2Ok2AWm/xRdVdn0rEvHd8s+VPXknjLxz7eUVDs5D5wndU9SKAWtajV3In1yECQQDR3XMije3xs2jGHMEbycV2/s6MNlxfkP7uUg5gIIxbVNaveUk0Q/DjC7/9phQfoi5wXmuQ6CH0qHvzll/+mciNAkEAoRaM61QzJQ6L1B8iqDsHGFqtjHa4tRKUUSEai+AYdBsQOYOpCDJ/lnY/pL9cuj81p1HTK/6lvTPuJOZClDeoBwJAAZabeHd6hYnGETnGfF9ajzv+dDE1IcQHKeaVFUUpyscpmMpiM3MQL6e3HERVgqfHkjIkvkQDfcaIqZ9JurOPQQJAJXjGbROYFh2tHzni6PlaLCsjxdH0I4Lf54No1nLZnWCSRJ7A2jxM+6YkJeGx401C4Noi4lAJI9sJoaHCiRHtTwJAbOmkvEfZ2BBYNNqhHPKeAWxpI6MuXiAJx96H0BIPQ5I1YFW+zy38VEmn7/LYrm/Qh6E0sNx322ZVMALfG67MWw=="

//微信
#define kWXAPP_ID @"wx3b1a795bf74dfbaa"
#define kWXAPP_SECRET @"430a1892eb0e1d35fa6eb6f804920948"

//JPUSH
#define kJPUSH_APP_ID @"b2b02c4b132e0e42cbe343f5"
#define kJPUSH_APP_SECRET @"b3e3b9cd627b25275946dd8e"

#define ACTIVITY_ID @3
#define RECT_LOG(f) NSLog(@"\nx:%f\ny:%f\nwidth:%f\nheight:%f\n",f.origin.x,f.origin.y,f.size.width,f.size.height)
#define NETWORK_ERROR @"网络错误"
#endif
