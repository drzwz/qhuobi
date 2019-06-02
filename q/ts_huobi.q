system"l qhuobi.q";
//保管好AccessKey和SecretKey !!!
accessKey:"AccessKey"; //请修改
secretKey:"SecretKey"; //请修改   

//策略举例，未考虑合约切换等
posfile:`:d:/data/ts_huobi/btc_pos;
mypos:@[get;posfile;0];  //读原有头寸标志
.z.ts:{
	//读取最新101个1分钟K线行情
	0N!(.z.Z;`getbars);
	r:apiget["/market/history/kline?period=1min&size=101&symbol=BTC_CQ"];
	$[r[`status]~"ok";bars::r`data;0N!(.z.Z;`bars_error;r)];
	//计算指标：hh/ll为最近x个K线的最高/低价,hh2/ll2为最近x个K线的最高/低价,lc为最近成交价
	hh:: max -1 _ exec high from bars;ll:: min -1 _ exec low from bars;
	hh2::max -30#-1 _ exec high from bars;ll2::min -30#-1 _ exec low from bars;
	lc::exec last close from bars;
	//下单
	/if[(mypos=0)&lc>hh;mypos:: 1;posfile set mypos;ol[`BTC;1] ];
	/if[(mypos=0)&lc<ll;mypos::-1;posfile set mypos;os[`BTC;1] ];
	/if[(mypos>0)&lc<ll2;mypos::0;posfile set mypos;cl[`BTC;1] ];
	/if[(mypos<0)&lc<hh2;mypos::0;posfile set mypos;cs[`BTC;1] ];
	};
system "t 10000";
