package  
{
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	import flash.system.Capabilities;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author qzd
	 */
	public class main extends MovieClip
	{
		private const bName:Array = new Array("encodeURI", "decodeURI", "unescape", "escape", "地理信息", "获得标准时间", "获得绝对时间", "NC测试", "call peerlist", "socket测试", "http测试", "当前分辨率", "统计事件测试", "视频测试", "进制转换", "clearInput", "clearOutput", "output2txt", "主站循环加载测试");
		private var bAr:Array = new Array();
		private var tFormat:TextFormat = new TextFormat();
		private var testNc:NetConnection = new NetConnection();
		private var testInfo:Array;
		private var testHost:String;
		private var testPort:int;
		private var bIndex:int;
		private var vPad:videoPad;
		private var isLoop:Boolean = false;
		private var loopTimer:Timer;
		private var loopSuc:int = 0;
        private var videoload:Httpload;
		private var retryNum:int = 1;
		public function main() 
		{
			var nameLength:int = bName.length;
			for (var i:int = 0; i < nameLength; i++) {
				bAr[i] = new myButton(bName[i]);
				this.addChild(bAr[i]);
				bAr[i].y = 33 + int(i / 5) * 30;
				bAr[i].x = 5 + i % 5 * 110;
				bAr[i].addEventListener(MouseEvent.CLICK, bClick);
			}
			tFormat.size = 12;
			output_t.setStyle("textFormat",tFormat);
			input_t.setStyle("textFormat", tFormat);
			vPad = new videoPad(this);
			addChild(vPad);
			vPad.visible = false;
			LoopCheck.addEventListener(MouseEvent.CLICK, CheckHandler); 
			
			videoload = new Httpload();
			videoload.addEventListener(Httpload.DISTRICTERROE,onVideoload);
			videoload.addEventListener(Httpload.IPERROE,onVideoload);
			videoload.addEventListener(Httpload.ONMETDATA,onVideoload);
			videoload.addEventListener(Httpload.VIDEOPLAY,onVideoload);
			videoload.addEventListener(Httpload.XMLERROR,onVideoload);
			videoload.addEventListener(Httpload.TIMECOMPLETE,onVideoload);
			videoload.x = output_t.width -50;
			videoload.y = output_t.y;
			
			addChild(videoload);
			this.videoload.visible = false;
			//this.addChild(new TheMiner());
		}
		function bClick(e:MouseEvent):void {
			bIndex = bAr.indexOf(e.target);
			switch(bName[bIndex]) {
				case "encodeURI":
					showOutput(encodeURI(input_t.text));
					break;
				case "decodeURI":
					showOutput(decodeURI(input_t.text));
					break;
				case "unescape":
					showOutput(unescape(input_t.text.replace(/\\\u/g, '%u')));
					break;
				case "escape":
					showOutput(escape(input_t.text).replace(/%u/g, '\\u').toLowerCase());
					break;
				case "地理信息":
					var httpLoader:URLLoader = new URLLoader();
					httpLoader.addEventListener(Event.COMPLETE, this.OnLoadComplete);
					httpLoader.addEventListener(IOErrorEvent.IO_ERROR, this.OnError);
					httpLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.OnError);
					httpLoader.load(new URLRequest("http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=js"));
					break;
				case "获得标准时间":
					showOutput(getTime(input_t.text,true),false);
					break;
				case "获得绝对时间":
					showOutput(getTime(input_t.text,false));
					break;
				case "NC测试":
					ncTest();
					break;
				case "call peerlist":
					if (isLoop) {
						CheckLoop();
					}else {
						callNcTest();
					}
					break;
				case "socket测试":
					if (isLoop) {
						CheckLoop();
					}else {
						socketTest();
					}
					break;
				case "http测试":
					if (isLoop) {
						CheckLoop();
					}else {
						httpTest();
					}
					break;
				case "当前分辨率":
					showOutput("当前分辨率：" + Capabilities.screenResolutionX + "*" + Capabilities.screenResolutionY);
					break;
				case "统计事件测试":
					sendToURL(new URLRequest(input_t.text));
					//ExternalInterface.call("sendSocketState","test1","testact","testlab",int(input_t.text));
					showOutput("提交统计>"+input_t.text);
					break;
				case "视频测试":
					if (!vPad.visible) {
						showVideo();
					}else {
						hideVideo();
					}
					break;
				case "进制转换":
					showOutput(changeNum());
					break;
				case "clearInput":
					input_t.text = "";
					break;
				case "clearOutput":
					output_t.text = "";
					break;
				case "output2txt":
					saveTxt(output_t.text);
					break;
				case "主站循环加载测试":
					var vid = input_t.text;
					if(!videoload.visible)
					{
						retryNum = 1;
						videoload.visible = true;
					    this.videoload.Run(vid);
					}else
					{
						retryNum= 1;
						videoload.visible = false;
						this.videoload.stop();
					}
					break;
				default:
					break;
			}
			output_t.verticalScrollPosition = output_t.maxVerticalScrollPosition;
		}
		private function OnConnectNetStatus(e:NetStatusEvent) : void
        {
			showOutput("OnConnectNetStatus:" + e.info.code);
			input_t.text = "";
			//testNc.removeEventListener(NetStatusEvent.NET_STATUS, this.OnConnectNetStatus);
			//testNc.close();
		}
		/**
		 *主站循环加载测试函数 
		 * @param e
		 * 
		 */		
		private function onVideoload(e:Event):void
		{
		    switch(e.type)
			{
			    case Httpload.DISTRICTERROE:
					showOutput("调度中心失败", false);
					break;
				case Httpload.IPERROE:
					showOutput("地域信息失败", false);
					break;
				case Httpload.ONMETDATA:
					showOutput("视频回调信息执行", false);
					break;
				case Httpload.VIDEOPLAY:
					showOutput("视频播放成功", false);
					break;
				case Httpload.XMLERROR:
					showOutput("xml加载失败", false);
					break;
				case Httpload.TIMECOMPLETE:
					showOutput("已循环次数"+ (retryNum++)+"\n\n", false);
				default:
					break;
			}
		}
		private function OnConnected(e:Event) : void
        {
			if (isLoop) {
				loopSuc++;
			}else {
				showOutput("连接成功!");
			}
			if (e.target.connected)
			{
				e.target.close();
			}
			e.target.removeEventListener(Event.CONNECT, OnConnected);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, socketError);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, socketError);
		}
		private function socketError(e:Event) {
			if (e.target.connected)
			{
				e.target.close();
			}
			showOutput("errorType:" + e);
			e.target.removeEventListener(Event.CONNECT, OnConnected);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, socketError);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, socketError);
		}
		private function getTime(timeStr:String, normal:Boolean):String {
			var timeS:String;
			var myDate:Date;
			if (timeStr == "") {
				myDate = new Date();
				if (normal) {
					timeS = ">" + myDate.fullYear + "." + (myDate.month + 1) + "." + myDate.date + "  " + myDate.hours + ":" + myDate.minutes + ":" + myDate.seconds;
				}else {
					timeS = ">" + myDate.time;
				}
			}else {
				if (normal) {
					var timeMark:Number = Number(timeStr);
					if (timeMark < 10000000000) {
						timeMark = timeMark * 1000;
					}
					myDate = new Date(timeMark);
					timeS = "对应标准时间:" + myDate.fullYear + "年" + (myDate.month + 1) + "月" + myDate.date + "日" + myDate.hours + ":" + myDate.minutes + ":" + myDate.seconds;
				}else {
					var tpN:Number = Date.parse(timeStr);
					if (isNaN(tpN)) {
						timeS = "格式错误，请参考如下格式(2000/01/01 00:00:00)\n";
					}else {
						timeS = "对应绝对时间:" + String(tpN);
					}
				}
			}
			return timeS;
		}
		private function OnLoadComplete(e:Event) : void
		{
			if (isLoop) {
				loopSuc++;
			}else {
				showOutput("页面请求成功");
				if (bName[bIndex] == "地理信息") {
					var str:String = e.target.data;
					showOutput(str);
					//try
					//{
						//str = str.replace("var remote_ip_info = ","");
						//var o:Object = com.adobe.serialization.json.JSON.decode(str);
						//for (var t in o) {
							//showOutput(t + ":" + o[t] + " | ",false);
						//}
						//showOutput(t + ":" + o[t]);
					//}
					//catch (err:Error)
					//{
						//showOutput("解析失败");
					//}
				}else {
					showOutput(e.target.data);
				}
			}
			e.target.removeEventListener(Event.COMPLETE, this.OnLoadComplete);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, this.OnError);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.OnError);
		}
		 private function OnError(e:Event) : void
        {
			showOutput("页面请求失败");
            e.target.removeEventListener(Event.COMPLETE, this.OnLoadComplete);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, this.OnError);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.OnError);
        }
		private function showVideo() {
			vPad.visible = true;
			vPad.x = 545 - vPad.width - 5;
			vPad.y = 470 - vPad.height - 5;
			vPad.playV(input_t.text);
		}
		private function hideVideo() {
			vPad.clearV();
			vPad.visible = false;
		}
		public function showOutput(msg:String, showtime:Boolean = true) {
			if(showtime){
				output_t.appendText(msg + "---" + getTime("", true) + "\n");
			}else {
				output_t.appendText(msg + "\n");
			}
		}
		private function callBack(msg:*) {
			if (isLoop) {
				loopSuc++;
			}else {
				var msg_sr:String="";
				switch(getQualifiedClassName(msg)) {
					case "String":
						msg_sr = msg;
						break;
					case "Object":
						for (var i:String in msg)
						{
							msg_sr += i + ":" + msg[i] + "\n";
						}
						break;
					case "Array":
						for (var n:int = 0; n < msg.length; n++) {
							msg_sr += "Ar(" + n + "):" + msg[n] + " ,";
						}
						break;
				}
				showOutput("返回>>" + msg_sr);
			}
		}
		private function saveTxt(msg:String) {
			var fr:FileReference = new FileReference();
			fr.save(msg, "log.txt");
		}
		private function CheckHandler(e:MouseEvent):void {
			isLoop = LoopCheck.selected;
			if (!isLoop && loopTimer) {
				stopLoop();
			}
		}
		private function CheckLoop() {
			if (loopTimer) {
				if (loopTimer.running) {
					loopTimer.reset();
					loopTimer.removeEventListener(TimerEvent.TIMER, timeHandle);
					loopTimer.removeEventListener(TimerEvent.TIMER, timeOut);
				}
				loopTimer = null;
			}
			trace(Number(loopDelay_t.text), Number(loopTime_t.text));
			loopTimer = new Timer(Number(loopDelay_t.text), Number(loopTime_t.text));
			loopTimer.addEventListener(TimerEvent.TIMER, timeHandle);
			loopTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeOut);
			loopSuc = 0;
			loopTimer.start();
		}
		private function timeOut(e:TimerEvent):void {
			stopLoop();
		}
		private function stopLoop() {
			if (loopTimer) {
				loopTimer.reset();
				loopTimer.removeEventListener(TimerEvent.TIMER, timeHandle);
				loopTimer.removeEventListener(TimerEvent.TIMER, timeOut);
				loopTimer = null;
			}
		}
		private function timeHandle(e:TimerEvent) {
			switch(bName[bIndex]) {
				case "NC测试":
					ncTest();
					break;
				case "call peerlist":
					callNcTest();
					break;
				case "socket测试":
					socketTest();
					break;
				case "http测试":
					httpTest();
					break;
			}
			score_t.text = "loop:" + e.target.currentCount + ">>>got:" + loopSuc;
		}
		
		private function httpTest() {
			var httpLoader:URLLoader = new URLLoader();
			httpLoader.addEventListener(Event.COMPLETE, this.OnLoadComplete);
			httpLoader.addEventListener(IOErrorEvent.IO_ERROR, this.OnError);
			httpLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.OnError);
			httpLoader.load(new URLRequest(input_t.text));
		}
		private function socketTest() {
			testInfo = input_t.text.split(":");
			testHost = testInfo[0];
			testPort = testInfo[1];
			var testSocket:Socket = new Socket();
			testSocket.connect(testHost, testPort);
			testSocket.addEventListener(Event.CONNECT, OnConnected);
			testSocket.addEventListener(IOErrorEvent.IO_ERROR, socketError);
			testSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socketError);
			showOutput("连接" + testInfo[0] + ":" + testInfo[1]);
		}
		private function ncTest() {
			if (testNc.connected) {
				testNc.close();
			}
			if (input_t.text.length > 1) {
				testNc.connect(input_t.text);
				testNc.addEventListener(NetStatusEvent.NET_STATUS, this.OnConnectNetStatus);
				showOutput("连接" + input_t.text);
			}else {
				showOutput("请输入地址,例：rtmfp://pp.xxx.com:1934");
			}
		}
		private function callNcTest() {
			if (testNc.connected) {
				if (input_t.text.length > 1) {
					this.testNc.call("getPeerList", new Responder(this.callBack), input_t.text,1);
					showOutput("call>>>"+input_t.text);
				}else {
					showOutput("请输入fid,例：2014-0704SVNC123113473002614941@xyz");
				}
			}else {
				showOutput("尚未连接服务器");
			}
		}
		private function changeNum():String {
			var tpAr:Array = input_t.text.split("/");
			if (tpAr.length == 3) {
				if (tpAr[1] == "10") {
					return Number(tpAr[0]).toString(int(tpAr[2]));
				}else {
					if (tpAr[2] == "10") {
						return String(parseInt(tpAr[0], int(tpAr[1])));
					}else {
						return parseInt(tpAr[0], int(tpAr[1])).toString(int(tpAr[2]));
					}
				}
			}
			return "请按以下格式输入》数据/原进制/转换进制，例：1001/2/10";
		}
	}
}