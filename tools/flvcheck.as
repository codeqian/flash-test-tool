package 
{
	
	
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * socket 检测flv文件存在类
	 * @author CZ
	 * 
	 */	
	public class flvcheck extends EventDispatcher
	{
		// host to connect
		private var _host:String = null;
		// port toEventDispatcherct
		private var _port:int = 80;
		// path to load
		private var _path:String = '/';
		// user agent of http request
		private var _userAgent:String = 'Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-CN; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10';
		// referer
		private var _referer:String = null;
		
		private var _socket:Socket = new Socket();
		private var _request:URLRequest = null;
		private var _bytes:Array = new Array();
		
		//private var _dispatcher:EventDispatcher = new EventDispatcher();
		
		private var _encoding:String = 'utf-8';
		
		// progress information 
		//private var _bytesLoaded:int = 0;
		//private var _bytesTotal:int = 0;
		private var _headerLength:int = 0;
		
		
		
		// url pattern
		//    group[1]: host
		//    group[2]: port
		//    group[3]: path
		
		/**
		 *头信息 
		 */		
		private var head:String;
		/**
		 *文件类型 
		 */		
		private var file_type:String;
		/**
		 *文件大小 
		 */		
		private var file_size:int;
		public static var FLVOK:String = "flv.ok";
		public static var FLVNO:String = "flv.no";
		private static const RULREDIRECTION:String = "url.redirection";
		private var redirectionUrl:String;
		/**
		 *重定向URL数组 
		 */		
		private var redirectionUrlArr:Array = new Array();
		
		/**
		 * constructor
		 *
		 * @param url:String
		 *    the request to load
		 * @return:
		 *    void
		 */
		public function flvcheck(request:URLRequest = null)
		{
			this._request = request;
		}
		
		/**
		 * load a request
		 *
		 * @param request:URLRequest
		 *    the request to load
		 * @return: 
		 *    void
		 */
		public function load(request:URLRequest = null):void
		{
			if (request != null)
			{
				this._request = request;
			}
			
			if (this._request == null)
			{
				throw new Error('the request cannot be null');
			}
			// parse url
			this._socket.addEventListener(Event.CLOSE, closeHandler);
			this._socket.addEventListener(Event.CONNECT, connectHandler, false, 0, true);
			this._socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			this._socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			this.addEventListener(RULREDIRECTION, Onredirection);
			this.init(this._request.url);
		}
		/**
		 *301 重定向函数; 
		 * @param event
		 * 
		 */		
		protected function Onredirection(event:Event):void
		{
			for(var i:String in redirectionUrlArr)
			{
			   if(redirectionUrl ==redirectionUrlArr[i])
			   {
				   this.dispatchEvent(new Event(FLVNO));
				   this.close()
				   return;
			   }
			}
				
			init(redirectionUrl);
		}
		/**
		 *初始话连接并连接 
		 * 
		 */		
		private function init(url:String):void
		{
			this.close();
			redirectionUrlArr.push(url);
			var URL_PATTERN:RegExp = /http:\/\/([^:\/]+)(?::(\d+))?(\/.*$)/i;
			var match:Object = URL_PATTERN.exec(url);
			if (match)
			{
				this._host = match[1];
				this._port = int(match[2]) || 80;
				this._path = match[3] || '/';
			}
			else
			{
				throw new Error('invalid url');
			}
			//XTrace.consoloTrace("socket 连接:"+this._host+":"+this._port);
			this._socket.connect(this._host, this._port);
			
		}
		
		//public function 
		/**
		 *关闭socket  抛出数据加载完成事件
		 * @param evt
		 * 
		 */			
		private function closeHandler(evt:Event):void
		{
		//	trace("socket流close");
			this.close();
		}
		
		private function connectHandler(evt:Event):void
		{
			//加载部分
			var headers:String = "GET " + this._path + " HTTP/1.1\r\n" + "Host: " + this._host + "\r\n" + "Accept: */*\r\n" + "User-Agent: Mozilla/4.0/1.1\r\n" + "Range: bytes=0-1\r\n" + "Connection: Keep-Alive\r\n" + "\r\n";
			// send request
			this._socket.writeUTFBytes(headers);
			this._socket.flush();
			// dispatch open event  抛出打开事件
			//dispatchEvent(new Event(flash.events.Event.OPEN));
		}
		/**
		 *IO错误 抛出事件 
		 * @param evt
		 * 
		 */		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			dispatchEvent(evt);
			this.close()
		}
		
		private function securityErrorHandler(evt:SecurityErrorEvent):void
		{
			dispatchEvent(evt);
			this.close()
		}
		/**
		 * socket 获取数据事件 
		 * @param evt
		 * 
		 */		
		private function socketDataHandler(evt:ProgressEvent):void
		{
			var ba:ByteArray = new ByteArray()
			this._socket.readBytes(ba, 0, this._socket.bytesAvailable);
			
			parseHeaders(ba);
			//trace("第一次socket头大小>>"+ba.length);
			//this.close();
		}
		/**
		 *解析头函数 (把不需要的头切掉)
		 * @param bytes
		 * 
		 */		
		private function parseHeaders(bytes:ByteArray):void
		{
			head = bytes.readUTFBytes(bytes.bytesAvailable);
			//trace("头信息"+head);
			var _loc_2:* = this.head.indexOf("\r\n\r\n");
			if (_loc_2 != -1)
			{
				_loc_2 = _loc_2 + 4;
				this.head = this.head.substring(0, _loc_2);//去除后面的信息
				
				AnalyzeHead(this.head);
				
			}
		}
		/**
		 *解析头 信息
		 * @param head  
		 * 
		 */		
		private function AnalyzeHead(head:Object):void
		{
			
			var division_int:int = 0;//分隔位置
			var division_str:String = null;//分隔得到的每个数据 
			var division_name:String = null;//分项名字
			var division_data:String = null;//对应名字的内容
			var _loc_10:Boolean = false;
			var _loc_11:uint = 0;
			
			var _loc_13:String = null;
			var division_Arr:Array = new Array();//存放分隔数据的数组
			var _loc_3:uint = 0;
			var  redirection:Boolean =Boolean (this.head.indexOf("301 Moved"));
		//	XTrace.consoloTrace("是否301: 真为有:"+this.head);
			while (this.head.length > 0)
			{
				if (_loc_3 > 100)
				{
					break;
				}
				division_int = this.head.indexOf("\r\n");
				if (division_int <= 0)
				{
					break;
				}
				division_str = this.head.substring(0, division_int);
				this.head = this.head.substr(division_int + 2, this.head.length - division_int - 2);
				division_Arr.push(division_str);
				_loc_3 = _loc_3 + 1;
			}
			var _loc_4:Boolean = false;
			var _loc_5:uint = 0;
			while (_loc_5 < division_Arr.length)
			{
				division_str = division_Arr[_loc_5];
				division_int = division_str.indexOf(":");
				if (division_int != -1)
				{
					division_name = division_str.substring(0, division_int);
					division_data = division_str.substring(division_int + 2);
					//XTrace.consoloTrace("返回内容division_name = "+division_name +"::"+division_data);
					if (division_name == "Content-Range")
					{
						_loc_10 = false;
						_loc_11 = 0;
						while (_loc_11 < division_Arr.length)
						{    
							_loc_13 = division_Arr[_loc_11].substring(0, division_Arr[_loc_11].indexOf(":"));
							if (_loc_13 == "Location")
							{
								_loc_10 = true;
								break;
							}
							_loc_11 = _loc_11 + 1;
						}
						if (_loc_10)
						{
							break;
						}
						file_size =parseInt( division_data.substring((division_data.indexOf("/") + 1)));
						//	得到文件大小然后抛出事件 TODO
					//	trace("Content-Range file size="+file_size);
						//this._bytesTotal = file_size;
						//this.close();
						
					}
					if (division_name == "Content-Length")
					{
						file_size = parseInt(division_data);
						//得到文件大小然后抛出事件 TODO
						//XTrace.consoloTrace("Content-Length file size="+file_size);
						
					}
					if (division_name == "Content-Type")
					{
					   file_type = division_data;//  text/html  video/x-flv
					//   XTrace.consoloTrace("文件类型"+file_type);
					}
					if(division_name == "Location"&&redirection)
					{//这个是重新定向的标记 内容为冲定向的地址 TDOD//暂时不做处理
					//	XTrace.consoloTrace("重定向url= "+division_data);
						redirectionUrl = division_data;
						this.head = "";
						this.dispatchEvent(new Event(RULREDIRECTION)); 
						return;
					}
				}
				else
				{
					//没有可分割的数据
				}
				_loc_5 = _loc_5 + 1;
			}
			judgeevent();
			return;
		}
		/**
		 * 判断事件抛出
		 * 
		 */		
		private function judgeevent():void
		{
			if(this.file_type =="video/x-flv"&&this.file_size >1024 )
			{//flv 文件 并且是正确的
				this.dispatchEvent(new Event(FLVOK));
				this.close()
			}else
			{ //地址不是正确的转到mp4
			   this.dispatchEvent(new Event(FLVNO));
			   this.close()
			}
			
		}
		/**
		 *关闭socket  
		 * 
		 */		
		public function close():void
		{
			//trace("close");
		   try{
			   if(this._socket.connected)
			   {
				   this._socket.close()
			   }
			  
		   }catch(e:Error)
		   {}
		  
		   this._host = "";
		   this._port = 80;
		   this._path = "";
		
		}
	}
}