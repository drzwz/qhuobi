# qhuobi

火币衍生品(www.hbdm.com)行情、交易接口及策略例子

# 用法

1、登录 <https://www.hbdm.com> ，在API管理中创建AccessKey和SecretKey。

2、用studio等支持q脚本的编辑器打开ts_huobi.q，修改AccessKey和SecretKey。并根据实际情况修改策略代码。行情和交易接口见qhuobi.q。

3、运行ts_huobi.bat启动策略例子。

## 注：
1.火币建议使用国外服务器访问API。在国内网络使用qhuobi可能因HTTP GET时出现锁死状态。
2.支持windows/linux

# 文件
ts_huobi.q  策略文件，一般只需要修改这个文件
qhuobi.q    行情和交易接口
cryptoq.q/cryptoq_binary.q HMAC_SHA256等签名算法
