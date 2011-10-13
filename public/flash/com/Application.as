/**
 * @author 	Sameer Jain
 * @Title	Flash Developer
 * @Company	Saachi Technologies [p] Ltd
 */
 package com 
{
	import flash.display.MovieClip;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.system.Security;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;

	public class Application extends MovieClip 
	{
		var appfacade:ApplicationFacade	=	ApplicationFacade.getInstance();
		//
		public static const START:String	=	"START" ;
		public static const RECORD:String	=	"RECORD" ;
		public static const PAUSE:String	=	"PAUSE" ;
		public static const RESET:String	=	"RESET";
		public static const PUBLISH:String	=	"PUBLISH";
		public static const PREVIEW:String	=	"PREVIEW";
		public static const PUBLISH_STATUS:String	=	"PUBLISH_STATUS";
		public function Application() 
		{
			stop();
			Security.allowDomain("*")
			loaderInfo.addEventListener(ProgressEvent.PROGRESS,showProgress);
			loaderInfo.addEventListener(Event.COMPLETE,removeProgress);
		}
		
		private function showProgress(e:ProgressEvent):void
		{
			var perc = Math.round((e.bytesLoaded/e.bytesTotal)*100)
		}
		private function removeProgress(e:Event)
		{
			stage.scaleMode 			= StageScaleMode.NO_SCALE;
			stage.align 				= StageAlign.TOP_LEFT;			
			appfacade.startup(this)
		}
	}
	
}
