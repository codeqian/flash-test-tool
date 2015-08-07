package 
{
		
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * 获取地域信息  IP 等 
	 * @author CZ
	 * 
	 */	
	public class Loaddistrict extends EventDispatcher
	{
		private var timer:Timer;
		private var loader:URLLoader;
		public var dist:Array;
		public static const  ERROR:String = "error.ip";
		public static const  COMPLETEIP:String = "ok.ip";
		public static var mydist:String = "330000";
		public static var myserv:String = "100026" ;
		public function Loaddistrict()
		{
			
			var url:String = "http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=js";
			this.timer = new Timer(2000,2);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.OnTimerComplete);
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, this.OnLoadComplete);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.OnTimerComplete);
			this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.OnTimerComplete);
			this.loader.load(new URLRequest(url));
			this.timer.reset();
			this.timer.start();
			return;
		}
		
		/**
		 *调度中心OK 
		 * @param event
		 * 
		 */		
		protected function OnLoadComplete(event:Event):void
		{
			var str:* = event.target.data;
			str = str.replace("(","");
			str = str.replace(")","");
			var o:Object =JSON.parse(str); //com.adobe.serialization.json.JSON.decode(str);
			this.dist = new Array();
			this.dist[0] = o.region;
			this.dist[1] = o.country;
			this.dist[2] = o.isp;
			this.dist[3] = o.ip;
			///XTrace.Log("diyu"+o.isp);
			mydist = this.dist[0];
			myserv = this.dist[2];
			this.timer.stop();
			this.timer.reset();
			dispatchEvent(new Event(COMPLETEIP));
		}
		/**
		 *调度中心失败 
		 * @param event
		 * 
		 */		
		protected function OnTimerComplete(event:TimerEvent):void
		{
			this.timer.stop();
			this.timer.reset();
			try
			{
				this.loader.close();
			}
			catch (e:Error)
			{
			}
			dispatchEvent(new Event(ERROR));
			return;
			
		}
	}
}