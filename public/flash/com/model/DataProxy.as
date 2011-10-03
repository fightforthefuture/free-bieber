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
	
	public class DataProxy extends Proxy
	{
		public static const NAME:String 		= 	"DataProxy";		
		public static const DATA_LOADED:String 	= 	"DATA_LOADED";		
		
		public static const host:String			=	"rtmp://ec2-107-20-93-100.compute-1.amazonaws.com/overlayrecorder";
		public static const publish:String		=	"http://ec2-107-20-93-100.compute-1.amazonaws.com:8080/publish.php";
		public static const poll:String			=	"http://ec2-107-20-93-100.compute-1.amazonaws.com:8080/status.php";
		public static var overlayimage:String;
		
		public static var filename:String;
		public static var recordtime:Number		=	10;
		public static var oildr:Loader			=	new Loader();
		//
		private var pUL:URLLoader				=	new URLLoader();
		private var pUR:URLRequest				=	new URLRequest();
		private var pID:String					;
		private var pTimer:Timer				=	new Timer(1000);
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
			var am:ApplicationMediator	=	facade.retrieveMediator(ApplicationMediator.NAME) as ApplicationMediator;
			am.startApp();
		}
		
		//publish call
		public function publishVideo():void
		{
			var uv:URLVariables	=	new URLVariables();
			uv.file				=	DataProxy.filename;
			uv.image				=	DataProxy.overlayimage;
			//
			pUR.data			=	uv;
			pUR.url				=	DataProxy.publish;
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
			ExternalInterface.call("debugRecording",id + " >> " + error);
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
			pUR.url				=	DataProxy.poll;
			pUR.data			=	uv;
			//
			pUL.dataFormat		=	URLLoaderDataFormat.TEXT;
			pUL.addEventListener(Event.COMPLETE,onVideoPublishStatus)
			pUL.load(pUR);
		}
		private function onVideoPublishStatus(e:Event):void
		{
			var xml				=	new XML(pUL.data);
			var status:String		=	xml.status.toString();
			if(status == "finished")
			{
				ExternalInterface.call("publishFinished");
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