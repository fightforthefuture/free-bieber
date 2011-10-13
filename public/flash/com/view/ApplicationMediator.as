package com.view
{
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.Application;
	import org.puremvc.as3.interfaces.INotification;
	import com.view.components.VideoRecord;
	import com.utils.VideoRecordEvent;
	import com.model.DataProxy;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class ApplicationMediator extends Mediator
	{
		public static const NAME:String 		= "ApplicationMediator";		
		public function ApplicationMediator( view:Application )
		{
			super(NAME, view);
		}
		
		override public function onRegister():void
		{
			
		}
		public function get view():Application
		{
			return viewComponent as Application;
		}
		public function startApp():void
		{
			
			view.addFrameScript(2,frame3)
			view.play();
		}
		private function frame3():void
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.addCallback("initRecording",initRecording1);
				ExternalInterface.addCallback("startRecording",startRecording1);
				ExternalInterface.addCallback("pauseRecording",pauseRecording1);
				ExternalInterface.addCallback("resetRecording",resetRecording1);
				ExternalInterface.addCallback("publishRecording",publishRecording1);
				ExternalInterface.addCallback("previewRecording",previewRecording1);
			}
			view.stop();
			var v:VideoRecord	=	new VideoRecord();
			view.addChild(v)
			facade.registerMediator( new VideoRecordMediator( v ));
			ExternalInterface.call("onLoad");
		}
		//
		public function attachOverlay():void
		{
			view.addChild(DataProxy.oildr);
			
			var vrm:VideoRecordMediator	=	facade.retrieveMediator(VideoRecordMediator.NAME) as VideoRecordMediator;
			DataProxy.oildr.x = vrm.view.x;DataProxy.oildr.y = vrm.view.y;DataProxy.oildr.width = vrm.view.width;DataProxy.oildr.height = vrm.view.height;
			
		}
		//external interface handlers
		private function initRecording1():void
		{
			sendNotification(Application.START);
		}
		private function startRecording1(params = null ):void
		{
			sendNotification(Application.RECORD);
		}
		private function pauseRecording1(params = null ):void
		{
			sendNotification(Application.PAUSE);
		}
		private function resetRecording1(params = null ):void
		{
			sendNotification(Application.RESET);
		}
		private function previewRecording1(params = null ):void
		{
			sendNotification(Application.PREVIEW);
		}
		
		private function publishRecording1( user = "", pass = "" ):void
		{
			sendNotification(Application.PUBLISH);
			
			var dp:DataProxy	=	facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			dp.publishVideo(user, pass)
		}
		//
		override public function listNotificationInterests():Array
		{
			//list notification
			return [ VideoRecordEvent.MEDIA_READY, VideoRecordEvent.MEDIA_UPDATE,VideoRecordEvent.MEDIA_PUBLISHING,VideoRecordEvent.MEDIA_PUBLISHED ]
		}
		override public function handleNotification(note:INotification):void
		{
			switch(note.getName())
			{
				case VideoRecordEvent.MEDIA_READY:
					ExternalInterface.call("mediaReady");
					attachOverlay();
					break;
				case VideoRecordEvent.MEDIA_UPDATE:
					ExternalInterface.call("mediaProgress",note.getBody().mediaPosition);
					break;
				case VideoRecordEvent.MEDIA_PUBLISHING:
					ExternalInterface.call("mediaSaving");
					break;
				case VideoRecordEvent.MEDIA_PUBLISHED:
					ExternalInterface.call("mediaSaved");
					break;
			}
		}
	}
}