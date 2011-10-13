package com.view
{
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.view.components.VideoRecord;
	import flash.events.Event;
	import com.model.DataProxy;
	import com.Application;
	import org.puremvc.as3.interfaces.INotification;
	import com.utils.VideoRecordEvent;
	import com.utils.Global;

	public class VideoRecordMediator extends Mediator
	{
		public static const NAME	:	String 	= 	"VideoRecordMediator";
		
		private var isSaving:Boolean	=	false;
		private var isPublishing:Boolean=	false;
		public function VideoRecordMediator( viewComponent:VideoRecord )
		{
			super(NAME, viewComponent);
		}
		override public function onRegister():void
		{
			view.fmsHost = Global.RTMP + Global.SERVER + "/" +  Global.RAPP;
			view.addEventListener(VideoRecordEvent.MEDIA_UPDATE,onMediaUpdate);
			view.addEventListener(VideoRecordEvent.MEDIA_COMPLETE,onMediaComplete);
			view.addEventListener(VideoRecordEvent.MEDIA_READY,onMediaReady);
			view.addEventListener(VideoRecordEvent.MEDIA_PUBLISHING,onMediaPublishing);
			view.addEventListener(VideoRecordEvent.MEDIA_PUBLISHED,onMediaPublished);
		}
		public function get view():VideoRecord
		{
			return viewComponent as VideoRecord;
		}
		private function onMediaReady(e:Event):void
		{
			view.height = view.stage.stageHeight;
			view.width = view.stage.stageWidth;
			sendNotification(VideoRecordEvent.MEDIA_READY,view);
		}
		private function onMediaComplete(e:Event):void
		{
			sendNotification(VideoRecordEvent.MEDIA_COMPLETE,view);
		}
		private function onMediaUpdate(e:Event):void
		{
			sendNotification(VideoRecordEvent.MEDIA_UPDATE,view);
		}
		private function onMediaPublishing(e:Event):void
		{
			sendNotification(VideoRecordEvent.MEDIA_PUBLISHING,view);
		}
		private function onMediaPublished(e:Event):void
		{
			if(isSaving)view.previewRecording(DataProxy.filename);
			else if(isPublishing) sendNotification(VideoRecordEvent.MEDIA_PUBLISHED,view);
		}
		//notifications
		override public function listNotificationInterests():Array
		{
			//list notification
			return [ Application.START,Application.RECORD,Application.PAUSE,Application.PUBLISH,Application.RESET ,Application.PREVIEW ];
		}
		override public function handleNotification(note:INotification):void
		{
			isSaving = false;
			isPublishing = false;
			switch (note.getName())
			{
				case Application.START :
					view.connectToHost();
					break;
				case Application.RECORD :
					view.startRecording(DataProxy.filename);
					break;
				case Application.PAUSE :
					view.pauseRecording();
					break;
				case Application.PUBLISH :
					isPublishing = true;
					view.publishRecording();
					break;
				case Application.PREVIEW:
					isSaving = true;
					view.publishRecording();
					break;
				case Application.RESET:
					view.resetRecording();
					break;
			}
		}
	}
}