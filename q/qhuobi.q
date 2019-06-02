//火币衍生品 API 
//目前只实现衍生品API部分REST接口功能
//衍生品API：https://github.com/huobiapi/API_Docs/wiki/REST_api_reference_Derivatives
/
接口类型 接口数据类型	请求方法						类型	描述						需要验签
Restful	基础信息接口	/api/v1/contract_contract_info	GET		获取合约信息				否
Restful	基础信息接口	/api/v1/contract_index			GET		获取合约指数信息			否
Restful	基础信息接口	/api /v1/contract_price_limit	GET		获取合约最高限价和最低限价	否
Restful	基础信息接口	/api/v1/contract_open_interest	GET		获取当前可用合约总持仓量	否
Restful	基础信息接口	/api/v1/contract_delivery_price	GET		获取预估交割价				否
Restful	市场行情接口	/market/depth					GET		获取行情深度数据			否
Restful	市场行情接口	/market/history/kline			GET		获取K线数据					否
Restful	市场行情接口	/market/detail/merged			GET		获取聚合行情				否
Restful	市场行情接口	/market/trade					GET		获取市场最近成交记录		否
Restful	市场行情接口	/market/history/trade			GET		批量获取最近的交易记录		否
Restful	资产接口		/api/v1/contract_account_info	POST	获取用户账户信息			是
Restful	资产接口		/api/v1/contract_position_info	POST	获取用户持仓信息			是
Restful	交易接口		/api/v1/contract_order			POST	合约下单					是
Restful	交易接口		/api/v1/contract_batchorder		POST	合约批量下单				是
Restful	交易接口		/api/v1/contract_cancel			POST	撤销订单					是
Restful	交易接口		/api/v1/contract_cancelall		POST	全部撤单					是
Restful	交易接口		/api/v1/contract_order_info		POST	获取合约订单信息			是
Restful	交易接口		/api/v1/contract_order_detail	POST	获取订单明细信息			是
Restful	交易接口		/api/v1/contract_openorders		POST	获取合约当前未成交委托		是
Restful	交易接口		/api/v1/contract_hisorders		POST	获取合约历史委托			是
Restful	交易接口		/api/v1/contract_matchresults	POST	获取历史成交记录			是
Restful	账户接口		/api/v1/futures/transfer		POST	币币账户和合约账户间进行资金的划转	是
\

if[not getenv[`KX_VERIFY_SERVER]~"NO";-1 "Please set KX_VERIFY_SERVER=NO !"];
system "l cryptoq.q";
//在策略脚本中赋值
accessKey:"";
secretKey:"";   

//http get and post
//apiget[api路径string，以/开始]，如apiget["/api/v1/contract_contract_info"]
apiget:{[apipath]httpresp:(`:https://api.hbdm.com) httpreq:"GET ",apipath," HTTP/1.1\r\nHost: api.hbdm.com"
        ,"\r\nContent-Type:application/x-www-form-urlencoded\r\nAccept-Language:zh-cn\r\n\r\n";
    :.j.k (4+first httpresp ss "\r\n\r\n") _ httpresp;
	};
//apipost[api路径string，以/开始;api参数string]，如 apipost["/api/v1/contract_account_info";""]
apipost:{[apipath;apidata]
	para_to_sign:"AccessKeyId=",accessKey,"&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=",ssr[ssr[-4 _ string[.z.z];".";"-"];":";"%3A"];  //.z.z UTC时间
	string_to_sign:"POST\napi.hbdm.com\n",apipath,"\n",para_to_sign;
	signature:ssr[;"%??";upper].h.hug["%",.Q.an] .cryptoq.b64_encode `char$.cryptoq.hmac_sha256[secretKey;string_to_sign];
	:.j.k .Q.hp["https://api.hbdm.com",apipath,"?",para_to_sign,"&Signature=",signature;.h.ty`json] apidata;
	};	
//行情例子
/获取合约信息: r:apiget["/api/v1/contract_contract_info"]; r[`status]返回请求处理结果"ok"或"error"，r[`data]为数据表，r`ts响应生成时间点，单位：毫秒
/获取合约指数：apiget["/api/v1/contract_index?symbol=BTC"]
/获取当前可用合约总持仓量: apiget["/api/v1/contract_open_interest?symbol=BTC&contract_type=this_week"]
/获取行情深度数据: apiget["/market/depth?symbol=BTC_CQ&type=step5"]
/更多例子见文档

//交易

//获取用户账户信息
getacc:getpor:{apipost["/api/v1/contract_account_info";""]};
por:{getpor[]`data};

//获取用户持仓信息 
getpos:{apipost["/api/v1/contract_position_info";""]};
pos:{getpos[]`data};

//订单状态  (1准备提交 2准备提交 3已提交 4部分成交 5部分成交已撤单 6全部成交 7已撤单 11撤单中)
getordstatus:{?[x<=3;`new;?[x=4;`partiallyfilled;?[x=6;`filled;?[x=11;`canceling;`canceled]]]]};

//合约下单 
/下单，参数为一dict，key为参数名，value为参数值，如setord `symbol`contract_type`contract_code`price`volume`direction`offset`lever_rate`order_price_type!(`BTC;`quarter;`;8700.0;1;`buy;`open;20;`limit)
/
参数名	参数类型	必填	描述
symbol	string	true	"BTC","ETH"...
contract_type	string	true	合约类型 ("this_week":当周 "next_week":下周 "quarter":季度)
contract_code	string	true	BTC180914
client_order_id	long	false	客户自己填写和维护，这次一定要大于上一次
price	decimal	true	价格
volume	long	true	委托数量(张)
direction	string	true	"buy":买 "sell":卖
offset	string	true	"open":开 "close":平
lever_rate	int	true	杠杆倍数[“开仓”若有10倍多单，就不能再下20倍多单]
order_price_type	string	true	订单报价类型 "limit":限价 "opponent":对手价 "post_only":只做maker单,post only下单只受用户持仓数量限制
\
setord:{[x]apipost["/api/v1/contract_order";.j.j x]};
/BTC季度合约以对手价开多ol、平多cl、开空os、平空cs
ol:{[sym;qty]0N!(.z.Z;`ol;sym;qty);setord `symbol`contract_type`contract_code`price`volume`direction`offset`lever_rate`order_price_type!(sym;`quarter;`;0;qty;`buy;`open;20;`opponent)};
cl:{[sym;qty]0N!(.z.Z;`cl;sym;qty);setord `symbol`contract_type`contract_code`price`volume`direction`offset`lever_rate`order_price_type!(sym;`quarter;`;0;qty;`sell;`close;20;`opponent)};
os:{[sym;qty]0N!(.z.Z;`os;sym;qty);setord `symbol`contract_type`contract_code`price`volume`direction`offset`lever_rate`order_price_type!(sym;`quarter;`;0;qty;`sell;`open;20;`opponent)};
cs:{[sym;qty]0N!(.z.Z;`cs;sym;qty);setord `symbol`contract_type`contract_code`price`volume`direction`offset`lever_rate`order_price_type!(sym;`quarter;`;0;qty;`buy;`close;20;`opponent)};

//撤销订单 c `order_id`client_order_id`symbol!(4;`;`BTC)
/
参数名称	是否必须	类型	描述
order_id	false	string	订单ID（ 多个订单ID中间以","分隔,一次最多允许撤消50个订单 ）
client_order_id	false	string	客户订单ID(多个订单ID中间以","分隔,一次最多允许撤消50个订单)
symbol	true	string	"BTC","ETH"...
备注： order_id和client_order_id都可以用来撤单，同时只可以设置其中一种，如果设置了两种，默认以order_id来撤单。
\
c:cancelord:{[x]apipost["/api/v1/contract_cancel";.j.j x]};

//全部撤单 cc `symbol`contact_code`contract_type!(`BTC;`;`)
/
参数名称	是否必须	类型	描述
symbol	true	string	品种代码，如"BTC","ETH"...
contract_code	false	string	合约code
contract_type	false	string	合约类型
\
cc:cancelall:{[x]apipost["/api/v1/contract_cancelall";.j.j x]};

//获取合约订单信息
/
参数名称	是否必须	类型	描述
order_id	false	string	订单ID（ 多个订单ID中间以","分隔,一次最多允许查询50个订单 ）
client_order_id	false	string	客户订单ID(多个订单ID中间以","分隔,一次最多允许查询50个订单)
symbol	true	string	"BTC","ETH"...
\
getord:{[x]apipost["/api/v1/contract_order_info";.j.j x]};

//获取订单明细信息
/
参数名称	是否必须	类型	描述
symbol	true	string	"BTC","ETH"...
order_id	true	long	订单id
created_at	true	long	下单时间戳
order_type	true	int	订单类型，1:报单 、 2:撤单 、 3:强平、4:交割
page_index	false	int	第几页,不填第一页
page_size	false	int	不填默认20，不得多于50
\
getorddetail:{[x]apipost["/api/v1/contract_order_detail";.j.j x]};

//获取合约当前未成交委托
/
参数名称	是否必须	类型	描述	默认值	取值范围
symbol	true	string	品种代码		"BTC","ETH"...
page_index	false	int			页码，不填默认第1页
page_size	false	int			不填默认20，不得多于50
\
getopenord:{[x]apipost["/api/v1/contract_openorders";.j.j x]};

//获取合约历史委托 gethistord[`symbol`trade_type`type`status`create_date!(`BTC;0;1;0;7)][`data]`orders
/
参数名称	是否必须	类型	描述	默认值	取值范围
symbol	true	string	品种代码	"BTC","ETH"...	
trade_type	true	int	交易类型	0:全部,1:买入开多,2: 卖出开空,3: 买入平空,4: 卖出平多,5: 卖出强平,6: 买入强平,7:交割平多,8: 交割平空	
type	true	int	类型	1:所有订单,2:结束状态的订单	
status	true	int	订单状态	0:全部,3:未成交, 4: 部分成交,5: 部分成交已撤单,6: 全部成交,7:已撤单	
create_date	true	int	日期	7，90（7天或者90天）	
page_index	false	int		页码，不填默认第1页	1
page_size	false	int		不填默认20，不得多于50 20
\
gethistord:{[x]apipost["/api/v1/contract_hisorders";.j.j x]};

//获取历史成交记录 gethisttrd[`symbol`trade_type`create_date!(`BTC;0;7)][`data]`trades
/
参数名称	是否必须	类型	描述	默认值	取值范围
symbol	true	string	品种代码		"BTC","ETH"...
trade_type	true	int	交易类型		0:全部,1:买入开多,2: 卖出开空,3: 买入平空,4: 卖出平多,5: 卖出强平,6: 买入强平
create_date	true	int	日期		7，90（7天或者90天）
page_index	false	int	页码，不填默认第1页	1	
page_size	false	int	不填默认20，不得多于50	20
\
gethisttrd:{[x]apipost["/api/v1/contract_matchresults";.j.j x]};