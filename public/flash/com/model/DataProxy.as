package com.model
{
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.net.URLLoader;
	import org.puremvc.as3.patterns.proxy.Proxy;
	import flash.display.Loader;
	import com.view.ApplicationMediator;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.Application;
	import flash.external.ExternalInterface;
	import com.utils.Global;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLRequestMethod;
	
	public class DataProxy extends Proxy
	{
		public static const NAME		:	String 		= 	"DataProxy";		
		public static const DATA_LOADED	:	String 		= 	"DATA_LOADED";		

		public static var overlayimage	:	String;
		public static var filename		:	String;
		public static var oildr			:	Loader		=	new Loader();
		
		private var chance				:	Number		=	0;
		//
		private var s1					:	Number		=	0;
		private var s2					:	Number		=	0;
		//
		private var pUL					:	URLLoader	=	new URLLoader();
		private var pUR					:	URLRequest	=	new URLRequest();
		private var pID					:	String;
		private var pTimer				:	Timer		=	new Timer(1000);
		public function DataProxy(proxyName:String=null, data:Object=null)
		{
			super(NAME, data);
		}
		public function loadTemplate( value:String = ""  ):void
		{
			var ur:URLRequest	=	new URLRequest( DataProxy.overlayimage );
			DataProxy.oildr.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadData)
			DataProxy.oildr.load(ur)
		} 	
		
		private function onLoadData(e:Event):void
		{
			//checking server
			checkServer();
		}
		public function checkServer():void
		{
			var uv:URLVariables	=	new URLVariables();
			var ur:URLRequest	=	new URLRequest();
			
			if(chance==0){uv.ip = Global.SERVER_1; ur.url =	Global.HTTP + Global.SERVER_1;}
			else if(chance==1){uv.ip = Global.SERVER_2;ur.url =	Global.HTTP + Global.SERVER_2;}
			
			ur.url				=	ur.url + ":" + Global.PORT+"/" + Global.CONNECT;
			ur.data				=	uv;
			var ul:URLLoader	=	new URLLoader(ur);
			
			ul.addEventListener(Event.COMPLETE,onServerStatus);
			ul.addEventListener(IOErrorEvent.IO_ERROR,onServerIOError);
			ul.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onServerSecurityError)
			//ul.addEventListener(HTTPStatusEvent.HTTP_STATUS,onServerHTTPStatus)
			ul.dataFormat		=	URLLoaderDataFormat.VARIABLES;
			ul.load(ur);
		}
		//connection file handler
		private function onServerStatus			(	e	:	Event				)	:	void 	{	var ul:URLLoader = e.target as URLLoader; 	testStatus( ul ); 	}
		private function onServerIOError		(	e	:	IOErrorEvent		)	:	void	{	var ul:URLLoader = e.target as URLLoader; 	testStatus( ul );	}
		private function onServerSecurityError	(	e	:	SecurityErrorEvent	)	:	void	{	var ul:URLLoader = e.target as URLLoader; 	testStatus( ul );	}
		private function onServerHTTPStatus		(	e	:	HTTPStatusEvent		)	:	void	{	var ul:URLLoader = e.target as URLLoader; 	testStatus( ul );	}
		//
		private function testStatus	(e:URLLoader):void
		{ 	
			var d:Object	=	e.data;
			if(d.server)
			{
				if(chance==0) s1 = d.server;
				else if(chance == 1) s2 = d.server;
			}
			if(chance==0)chance = 1;
			else if(chance == 1)chance = 2;
			
			if(chance==1)checkServer();
			else testServer()
		}
		private function testServer()
		{
			if(s1>s2)	Global.SERVER = Global.SERVER_2;
			else		Global.SERVER = Global.SERVER_1;
			
			var am:ApplicationMediator	=	facade.retrieveMediator(ApplicationMediator.NAME) as ApplicationMediator;
			am.startApp();
		}
		//publish call
		public function publishVideo(user = "", pass = ""):void
		{
			var uv:URLVariables	=	new URLVariables();
			uv.file				=	DataProxy.filename;
			uv.image			=	DataProxy.overlayimage;
			uv.ip 				= 	Global.SERVER;
			uv.user				=	user;
			uv.pass				=	pass;
			//
			pUR.data			=	uv;
			pUR.method			=	URLRequestMethod.POST
			pUR.url				=	Global.HTTP + Global.SERVER + ":" + Global.PORT+ "/" + Global.PUBLISH;
			//
			pUL.dataFormat		=	URLLoaderDataFormat.VARIABLES;
			pUL.addEventListener(Event.COMPLETE,onVideoStatus)
			pUL.load(pUR);
		}
		
		private function onVideoStatus(e:Event):void
		{
			pUL.removeEventListener(Event.COMPLETE,onVideoStatus)
			var id:String		=	pUL.data.id;
			var error:String	=	pUL.data.error;
			//ExternalInterface.call("debugRecording",id + " >> " + error);
			if(!error)
			{	
				pID = id;
				startPoll()
			}
		}
		private function startPoll():void
		{
			var uv:URLVariables	=	new URLVariables();
			uv.id				=	pID;
			//
			pUR.url				=	Global.HTTP + Global.SERVER+ ":" + Global.PORT + "/" + Global.STATUS;;
			pUR.data			=	uv;
			//
			pUL.dataFormat		=	URLLoaderDataFormat.TEXT;
			pUL.addEventListener(Event.COMPLETE,onVideoPublishStatus)
			pUL.load(pUR);
		}
		private function onVideoPublishStatus(e:Event):void
		{
			var xml				=	new XML(pUL.data);
			var status:String	=	xml.status.toString();
			//ExternalInterface.call("debugRecording",status);
			if(status == "finished")
			{
				var link	=	xml.links.link.toString();
				ExternalInterface.call("publishFinished",link);
			}
			else if(status=="failed")
			{
				var error	=	xml.errors.error.toString();
				ExternalInterface.call("publishError",error);
			}
			else
			{
				var uploads				=	xml.uploads.upload
				if(uploads.length()>0)
				{
					var percent:String		=	uploads[0].@percent;
					var transferred:String	=	uploads[0].@transferred;
					var total:String		=	uploads[0].@total;
					var speed:String		=	uploads[0].@speed;
					ExternalInterface.call("publishProgress",status,percent,transferred,total,speed);
				}
				//
				pTimer.addEventListener(TimerEvent.TIMER,onTimer)
				pTimer.start()
			}
		}
		private function onTimer(e:TimerEvent):void
		{
			pTimer.stop();
			startPoll()
		}
	}
}