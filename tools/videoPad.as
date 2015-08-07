package  
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	/**
	 * ...
	 * @author qzd
	 */
	public class videoPad extends Sprite
	{
		private var bgSp:Sprite;
		private var _Video:Video;
		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var vInfo:TextField;
		private var pauseButten:myButton;
		private var playButten:myButton;
		private var mainCtrl:*;
		public function videoPad(_main:*) 
		{
			mainCtrl = _main;
			creatBg();
			_nc = new NetConnection();
			_nc.connect(null);
			_ns = new NetStream(_nc);
			var _Video:Video = new Video(320, 240);
			_Video.smoothing = true;
			_Video.deblocking = 2;
			_Video.attachNetStream(_ns);
			addChild(_Video);
			var _client:Object = new Object();
			_client.onMetaData = onMetaDataFunc;
			_ns.client = _client;
			vInfo = new TextField();
			addChild(vInfo);
			vInfo.background = true;
			vInfo.backgroundColor = 0x000000;
			vInfo.textColor = 0xffffff;
			vInfo.text = "vinfo";
			vInfo.width = 320;
			vInfo.height = 20;
			pauseButten = new myButton("pause");
			addChild(pauseButten);
			pauseButten.y = 216;
			pauseButten.addEventListener(MouseEvent.CLICK, pauseClick);
			playButten = new myButton("play");
			addChild(playButten);
			playButten.y = 216;
			playButten.x = 105;
			playButten.addEventListener(MouseEvent.CLICK, playClick);
		}
		private function creatBg() {
			bgSp=new Sprite();
			this.addChild(bgSp);
			bgSp.graphics.beginFill(0x000000);
			bgSp.graphics.drawRect(0, 0, 320, 240);
			bgSp.graphics.endFill();
		}
		public function clearV() {
			_nc.close();
			_ns.close();
			_ns.dispose();
		}
		public function playV(url:String) {
			_ns.play(url);
		}
		private function onMetaDataFunc(data:Object):void
		{
			vInfo.text = data.duration + "   " + data.width + "x" + data.height;
			for(var i:String in data){
				mainCtrl.showOutput("onMetaData_"+i+":"+data[i]);
			}
		}
		private function pauseClick(e:MouseEvent):void {
			_ns.pause();
		}
		private function playClick(e:MouseEvent):void {
			_ns.resume();
		}
	}
}