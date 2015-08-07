package
{
	import com.adobe.crypto.MD5;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.LocalConnection;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.System;
	import flash.utils.Timer;

	/**
	 * 数据加载类 
	 * @author CZ
	 * 
	 */	
	public class Httpload extends Sprite
	{
		public var xmlurl:String;
		public var dataXML:XML;
		public var videourl:String;
		public var videotime:String;
		public var videoxmlvid:String;
		public var districtok:Boolean;
		public var xmlloadok:Boolean;
		public var videovid:String;
		public var vType:int;
		
		//private var _Video:Video;
		private var _nc:NetConnection;
		private var _ns:NetStream;
		/**
		 *区别是高清视频还是普通 
		 */		
		public var Length:int;
		/**
		 *视频播放事件 
		 */		
		public static const VIDEOPLAY:String = "video.play.full";
		/**
		 *视频 onMetaData 回调执行事件
		 */		
		public static const ONMETDATA:String = "onMetaData.ok";
		/**
		 *调度中心失败事件 
		 */		
		public static const DISTRICTERROE:String = "district.error";
		/**
		 *xml加载失败 
		 */		
		public static const XMLERROR:String = "xml.load.error";
		/**
		 *地域信息失败 
		 */		
		public static const IPERROE:String = "ip.load.error";
		public static const TIMECOMPLETE:String = "time.complete"
		public var time:Timer = new Timer(20000);
		/**
		 *
		 * @param 
		 * 
		 */		
		public function Httpload()
		{
			this.time.addEventListener(TimerEvent.TIMER , onTime);
			return;
		}
		public function onTime(e:TimerEvent):void
		{
			 this.dispatchEvent(new Event(TIMECOMPLETE));
		     this.clrearvideo();
			 this.Run(videovid);
		}
		/**
		 *停止加载 
		 * 
		 */		
		public function stop():void
		{
		    this.time.reset();
			this.time.stop();
			this.clrearvideo();
			
			
		}
		/**
		 *run 函数 执行加载
		 * @param vid
		 * 
		 */		
		public function Run(vid:String):void
		{
			xmlurl = ""+vid+".xml";
			videovid = vid
			this.time.reset();
			this.time.start();
			var xmlload:URLLoader = new URLLoader();
			xmlload.addEventListener(Event.COMPLETE ,xmlcomplete);
			xmlload.addEventListener(IOErrorEvent.IO_ERROR,xmlerror);
			xmlload.addEventListener(SecurityErrorEvent.SECURITY_ERROR,xmlerror);
			xmlload.load(new URLRequest(xmlurl));
			var loaddistrict:Loaddistrict = new Loaddistrict();
			loaddistrict.addEventListener(Loaddistrict.COMPLETEIP, onIpcomplete);
			loaddistrict.addEventListener(Loaddistrict.ERROR,onIperror);
		}
		/**
		 *地域成功 
		 * @param e
		 * 
		 */		
	    private function onIpcomplete(e:Event):void
		{
			this.districtok = true;
			if(this.xmlloadok&&this.districtok)
			{
				this.dispatchUrl();
			}
		}
		/**
		 *地域获取失败 
		 * @param e
		 * 
		 */		
		private function onIperror(e:Event):void
		{
			this.districtok = true; //失败用默认 
			//TODO 得把失败信息输出
			this.dispatchEvent(new Event(IPERROE));
			if(this.xmlloadok&&this.districtok)
			{
				this.dispatchUrl();
			}
		}
		/**
		 *xml加载成功 
		 * @param e
		 * 
		 */		
		private function xmlcomplete(e:Event):void
		{ 
			this.xmlloadok = true;
			dataXML = XML(e.target.data);
		    videourl =  dataXML.child("video").child("fileUrl").child("file").toString();
			videotime =  (dataXML.child("video").child("totalDuration").toString());
			videoxmlvid = dataXML.child("video").child("vid").toString();
			if(this.xmlloadok&&this.districtok)
			{
				this.dispatchUrl();
			}
		}
		/**
		 *xml 加载失败  
		 * @param e
		 * 
		 */		
		private function xmlerror(e:Event):void
		{
			this.xmlloadok = false;
			this.dispatchEvent(new Event(XMLERROR));
			//TODO  打印错误消息
		}
		
		/**
		 *调度中心 
		 * 
		 */		
		private function dispatchUrl():void
		{
			
		}
		/**
		 * load 调度中心地址
		 * @param url
		 * 
		 */		
		private function loaderDistrictURL(url:String):void
		{
			var loader:URLLoader = new URLLoader();   
			loader.addEventListener(Event.COMPLETE, DistrictComplete);  
			loader.addEventListener(IOErrorEvent.IO_ERROR,onIOErrorDistrict);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onIOErrorDistrict);
			loader.load(new URLRequest(url));   
		}
		/**
		 *调度成功   
		 * @param e
		 * 
		 */		
		private function DistrictComplete(event:Event):void
		{
			var str:String= String(event.target.data);//获得数据
			try{
				var dictionaryData:* = JSON.parse(str);
				if(dictionaryData.error =="500" )
				{
					//XTrace.consoloTrace("调度中心返回的数据200")
					//this.regetUrl();
					//XTrace.Log("调度中心失败播放1",true);
					this.playUrl();
				}else if(dictionaryData.error == "404")
				{
					//TODO 直接跳转 没有视频   放到输出 直接跳转了
					//ExternalInterface.call("openRelate");
					this.dispatchEvent(new Event(DISTRICTERROE));
				}
				else 
				{
					var tempurl:String = dictionaryData.url +"?"+ dictionaryData.t+"&start=0";
					//XTrace.Log("调度中心得到视频地址"+reportURI.flvUrl_arr[0]);
					this.videourl = tempurl;
					if(this.vType==2)
					{
						if(tempurl.indexOf(".flv"))
						{
							var flvload:flvcheck = new flvcheck();
							flvload.load(new URLRequest(tempurl));
							flvload.addEventListener(flvcheck.FLVOK, Onflvcheck);
							flvload.addEventListener(flvcheck.FLVNO, Onflvcheck);
							flvload.addEventListener(IOErrorEvent.IO_ERROR , Onflvcheck);
							flvload.addEventListener(SecurityErrorEvent.SECURITY_ERROR, Onflvcheck);
						}else
						{
							this.playUrl();
						}
					}else
					{
						this.playUrl();
					}
					
				}
			}catch(e:Error)
			{
				this.playUrl();
			}
		}
		
		/**
		 *播放视频 
		 * @return 
		 * 
		 */		
		public function playUrl()
		{
			var bgSp:Sprite=new Sprite();
			this.addChild(bgSp);
			bgSp.graphics.beginFill(0x000000);
			bgSp.graphics.drawRect(0, 0, 50, 50);
			bgSp.graphics.endFill();
			_nc = new NetConnection();
			_nc.connect(null);
			_ns = new NetStream(_nc);
			var _Video:Video = new Video(50, 50);
			_Video.smoothing = true;
			_Video.deblocking = 2;
			_Video.attachNetStream(_ns);
			addChild(_Video);
			var _client:Object = new Object();
			_client.onMetaData = onMetaDataFunc;
			_ns.client = _client;
			_ns.play(this.videourl);
			_ns.addEventListener(NetStatusEvent.NET_STATUS,onNetstatus);
		}
		/**
		 *清理函数 
		 * 
		 */		
		public function clrearvideo():void
		{
			System.gc();
			try {
				var lc1: LocalConnection = new LocalConnection (); 
				var lc2: LocalConnection = new LocalConnection ();  
				lc1.connect(  "gcConnection" );  
				lc2.connect(  "gcConnection" ); 

			} catch (e:*) {}
			
			_nc.close();
			_ns.close();
			_ns.dispose();
			xmlurl:String;
			dataXML = null;
			videourl = null;
			videotime =null;
			videoxmlvid = null;
			districtok = false;
			xmlloadok = false;
			vType = 0;
			this.Length = 0;
			
		}
		
		/**
		 *视频状态信息 
		 * @param e
		 * 
		 */		
		private function onNetstatus(e:NetStatusEvent):void
		{
			switch(e.info.code)
			{
			   case "NetStream.Buffer.Full":
				   this.dispatchEvent(new Event(VIDEOPLAY)); 
				   break;
			   default:
				   break;
			
			}
		}
		/**
		 *视频信息的回调 
		 * @param data
		 * 
		 */		
		private function onMetaDataFunc(data:Object):void
		{
			//vInfo.text = data.duration + "   " + data.width + "x" + data.height;
			//for(var i:String in data){
				//mainCtrl.showOutput("onMetaData_"+i+":"+data[i]);
			//}
			this.dispatchEvent(new Event(ONMETDATA));
		}
		/**
		 *检测flv是否存在处理函数 
		 * @param event
		 * 
		 */		
		protected function Onflvcheck(event:Event):void
		{
			switch(event.type)
			{
				case flvcheck.FLVOK:
					this.playUrl();
					break;
				default:
					this.videourl =this.videourl.replace(".flv",".mp4");
					this.playUrl();
					break;
				
			}
		}
		/**
		 *调度失败 
		 * @param e
		 * 
		 */		
		private function onIOErrorDistrict(e:Event):void
		{
			this.dispatchEvent(new Event(DISTRICTERROE));
		}
		
	}
}