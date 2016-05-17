//
//  ApiUri.h
//  Decorate
//
#ifndef Ebt_ApiUri_h
#define Ebt_ApiUri_h

//#if DEBUG
//#define HOST_URL @"http://192.168.1.117/?/ios_api"
//#define HOST_PATH @"http://192.168.1.103/"
//#else
#define HOST_URL @"http://m.ybt999.com/?/ios_api"
#define HOST_PATH @"http://m.ybt999.com/"
//#endif


#define user_login @"user/login" //登陆。@{@"username":mobile,@"password":password}
#define user_register @"user/register" //注册。@{@"username":mobile,@"password":password,@"code":验证码}
#define user_sendRegCode @"user/sendRegCode" //发送注册验证码。@{@"username":mobile}
#define user_loginByWx @"user/loginByWx" //微信注册。@{@"nickName":昵称,@"headerImage":头像,@"openid":openid}
#define user_bindMobile @"user/bindMobile" //微信注册绑定手机。@{@"uid":用户id,@"SessionId":安全token,@"mobile":手机号码,@"code":验证码}

#define home_indexMsg @"home/indexMsg" //获取首页获奖消息。
#define data_slides @"data/slides" //获取首页Banner。
#define home_qiandao @"home/qiandao" //签到。@{@"uid":用户id}
#define data_appSetting @"data/appSetting" //获取配置信息。

#define lottery_award @"lottery/award" //抽奖。@{@"uid":用户id,@"SessionId":安全token}
#define lottery_activityLottery @"lottery/activityLottery" //获奖列表。@{@"uid":用户id}

#define user_sendMsgCode @"user/sendMsgCode" //发送忘记密码验证码。@{@"username":mobile}
#define user_sendBindCode @"user/sendBindCode" //发送绑定验证码。@{@"username":mobile, @"username":mobile}
#define user_resetPwd @"user/resetPwd" //修改密码。@{@"username":mobile,@"password":password,@"code":验证码}
#define user_updateProfile @"user/updateProfile" //修改资料。@{@"name":昵称,@"realName":真实姓名,@"cardNum":身份证,@"uid":用户Id,@"SessionId":安全token}
#define user_changeTou @"user/changeTou" //修改头像。@{@"uid":用户Id,@"Filedata":图片,@"SessionId":安全token}
#define user_detail @"user/detail" //查询用户信息。@{@"uid":用户Id,@"SessionId":安全token}
#define user_profileChange @"user/profileChange" //查询用户信息。@{@"uid":用户Id,@"SessionId":安全token,@"sex":(男/女),@"username":昵称}
#define user_yaoQingList @"user/yaoQingList" //获奖列表。@{@"uid":用户id,@"SessionId":安全token}
#define user_recordList @"user/recordList" //账户明细。@{@"uid":用户id,@"SessionId":安全token}
#define user_shareScore @"user/shareScore" //账户明细。@{@"uid":用户id,@"SessionId":安全token}


#define user_moneyRecord @"user/moneyRecord" //通币消费记录。@{@"uid":用户Id,@"SessionId":安全token}
#define user_scoreRecord @"user/scoreRecord" //通豆消费记录。@{@"uid":用户Id,@"SessionId":安全token}
#define user_rechargeRecord @"user/rechargeRecord" //充值记录。@{@"uid":用户Id,@"SessionId":安全token}

#define user_involvedGoods @"user/involvedGoods" //参与购买的商品。@{@"uid":用户ID，“page”:页码,@"state":(-1:全部，1：进行中，其他：已揭晓)}
#define user_prizesList @"user/prizesList" //我的奖品。@{@"uid":用户ID，“page”:页码}
#define user_shaidanList @"user/shaidanList" //晒单记录。@{@"uid":用户ID，“page”:页码}
#define user_shaidanCreate @"user/shaidanCreate" //晒单发布。@{@"uid":用户Id,@"SessionId":安全token,@"content":内容,@"Filedata":files数组}

#define goods_glist @"goods/glist" //商品列表。@{@"cid":类型id(10,20,...)，@"orderBy":排序，@"index":(1/0)}
#define goods_goodsDetail @"goods/goodsDetail" //商品详情。@{@"goods_id":商品id}
#define goods_goodsDetailByQishu @"goods/goodsDetailByQishu" //商品详情。@{@"sid":商品sid,@"qishu":期数}
#define goods_categoryList @"goods/categoryList" //分类列表。@{@"model":类型（－1：任务，1:商品，2：文章，默认是1）}
#define goods_involvedList @"goods/involvedList" //商品通沟记录。@{@"goods_id":商品id}
#define goods_listByIds @"goods/listByIds" //商品列表。@{@"ids":JSON array()}
#define goods_sdListBySid @"goods/sdListBySid" //晒单列表。@{@"sid":商品sid}

#define order_detail @"order/detail" //订单详情。@{@"orderId":订单ID，“goodsId”:商品ID}
#define order_reserve @"order/reserve" //预约，选择商家。@{@"uid":用户ID，“goodsId”:商品ID，“orderId”:订单ID，“businessId”:商家ID}
#define order_payWelfare @"order/payWelfare" //支付公益金。@{@"sn":orderSn，@"uid":用户Id,@"SessionId":安全token,}
#define order_payWelfareAction @"order/payWelfareAction" //支付公益金。@{@"orderId":订单ID，@"uid":用户Id,@"SessionId":安全token,}
#define order_payWelfareByBalance @"order/payWelfareByBalance" //支付公益金。@{@"orderId":订单ID，“orderCode”:订单流水号}
#define order_receive @"order/receive" //确认收货。@{@"uid":用户ID，“goodsId”:商品ID，“orderId”:订单ID}
#define order_payByBalance @"order/payByBalance2" //余额支付。@{@"uid":用户Id,@"SessionId":安全token,@"Mcartlist":JSON array}
#define order_payOrderAction @"order/payOrderAction" //余额支付。@{@"uid":用户Id,@"SessionId":安全token,@"Mcartlist":JSON array}
#define order_modeChange @"order/modeChange" //确认收货。@{@"uid":用户ID，“mode”:(1:自助，2:客服)，“orderId”:订单ID}
#define order_payToSafari @"order/payToSafari" //余额浏览器支付。@{@"uid":用户Id,@"SessionId":安全token,@"Mcartlist":JSON array}
#define order_payBySafari @"order/payBySafari" //余额浏览器支付。@{@"safariSn":safariSn}
#define order_infoBySafariSn @"order/infoBySafariSn" //余额浏览器支付信息。@{@"uid":用户Id,@"SessionId":安全token,@"safariSn":safariSn单号}
#define order_payOrder @"order/payOrder" //余额支付。@{@"uid":用户Id,@"SessionId":安全token,@"sn":orderSn}





#endif