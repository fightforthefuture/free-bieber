package com.view.components
{
	import flash.display.MovieClip;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.utils.Timer;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.net.NetStream;
	import flash.events.SecurityErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import fl.controls.ProgressBar
	import com.utils.VideoRecordEvent;
	import flash.events.ActivityEvent;
	import flash.system.System;
	import flash.system.Capabilities;
	import flash.external.ExternalInterface;

	public class VideoRecord extends Video 
	{
		private var _fmsHost		:String = ""
		//
		private var bandwidth:int = 0; // Specifies the maximum amount of bandwidth that the current outgoing video feed can use, in bytes per second. To specify that Flash Player video can use as much bandwidth as needed to maintain the value of quality , pass 0 for bandwidth . The default value is 16384.
		private var quality:int = 75; // this value is 0-100 with 1 being the lowest quality. Pass 0 if you want the quality to vary to keep better framerates

		private var connection		:	NetConnection;
		private var stream			:	NetStream;
		private var pstream			:	NetStream;
		private var connectTimer	:	Timer;
		private var bufferTimer		:	Timer;
		private var trackTimer		:	Timer;
		private var inited			:	Boolean 		= false
		//media
		private var yourCam			:	Camera;
		private var yourMic			:	Microphone;
		//progress
		private var _mediaDuration	:	Number;
		private var _recordedTime	:	Number			=	0;
		//
		private var state			:String				=	"record"
		public function VideoRecord() 
		{
			trace(this)
		}
		//
		public function connectToHost():void
		{
			trackTimer = new Timer(1)
			connection = new NetConnection();
            connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, aSynchHandler);
            connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(fmsHost);
			//
			connectTimer = new Timer(5000)
			connectTimer.addEventListener(TimerEvent.TIMER,onConnectTimer)
			connectTimer.start()
			//
			bufferTimer = new Timer(250);
		}
		public function disconnectToHost():void{stream.publish();connection.close()}
		private function aSynchHandler(e){	trace(e) }
		private function securityErrorHandler(event:SecurityErrorEvent):void { /*_control.status_txt.text = ("Status: SecurityError: " + event);*/ }
		private function netStatusHandler(event:NetStatusEvent):void {trace(event.info.code); if (event.info.code == "NetConnection.Connect.Success")  { inited = true; connectTimer.stop();attachMedia();}else{}}
		//test connection
		private function onConnectTimer(e) { if(inited == false) { connection.connect(fmsHost); } else { connectTimer.stop(); } }
		//attachwebcam
		private function attachMedia()
		{
			var os:String		=	Capabilities.os.toLowerCase();
			var cameras:Array	=	Camera.names;
			var cameraid:Number	=	0;
			for (var i in cameras)
			{ 
				var n:String = cameras[i].toLowerCase(); 
				if(n.search("usb"))
				{
					cameraid=i;
					break
				}
			}
			yourCam 	= 	Camera.getCamera(String(cameraid))
			
			
			width 		= 	yourCam.width
			height		=	yourCam.height
			yourMic 	= 	Microphone.getMicrophone();
			yourMic.setSilenceLevel(0);
			yourMic.rate = 44;
			//yourMic.setUseEchoSuppression(true);
			
			yourCam.addEventListener(ActivityEvent.ACTIVITY, activityHandler);
			
			stream = new NetStream(connection);
			pstream= new NetStream(connection);
			stream.client = this;
			pstream.client = this;
			//
			this.attachCamera(yourCam)
		}
		 private function activityHandler(e:ActivityEvent):void 
		 {
			yourCam.removeEventListener(ActivityEvent.ACTIVITY, activityHandler);
            if(e.activating)
			{
				
				dispatchEvent(new Event(VideoRecordEvent.MEDIA_READY));
				yourCam.setQuality(bandwidth, quality);
				yourCam.setMode(width,height,yourCam.fps,true); // setMode(videoWidth, videoHeight, video fps, favor area)

			}
        }
		private function startTrackProgress(b:Boolean):void
		{
			if (b)
			{
				trackTimer = new Timer(40)
				trackTimer.addEventListener(TimerEvent.TIMER,trackProgress)
				trackTimer.start()
			} else
			{
				trackTimer.stop()
				trackTimer.removeEventListener(TimerEvent.TIMER,trackProgress)
				dispatchEvent(new Event(VideoRecordEvent.MEDIA_UPDATE))
			}
		}
		private function trackProgress(e = null ):void
		{	
			dispatchEvent(new Event(VideoRecordEvent.MEDIA_UPDATE))
		}
		private function bufferProgress()
		{
			var buffLen:Number = stream.bufferLength;
			if (buffLen == 0)
			{
				_recordedTime	=	0;
				bufferTimer.stop();
				stream.publish("null");
				bufferTimer.removeEventListener(TimerEvent.TIMER,bufferProgress)
				dispatchEvent(new Event(VideoRecordEvent.MEDIA_PUBLISHED))
			}
			dispatchEvent(new Event(VideoRecordEvent.MEDIA_PUBLISHING))
		}
		
		//PUBLIC
		public function get mediaPosition():Number{return  _recordedTime + stream.time;}
		public function startRecording(value:String="test"){closePlayBack();stream.attachCamera(yourCam);stream.attachAudio(yourMic);stream.publish(value,state);startTrackProgress(true);}
		
		public function publishRecording()
		{
			stream.attachAudio(null);
			stream.attachCamera(null);
			startTrackProgress(false);
			
			var buffLen:Number = stream.bufferLength;
			if (buffLen > 0)
			{
				bufferTimer.addEventListener(TimerEvent.TIMER,bufferProgress);
				dispatchEvent(new Event(VideoRecordEvent.MEDIA_PUBLISHING));
			}
			else
			{
				stream.publish("null");
				dispatchEvent(new Event(VideoRecordEvent.MEDIA_PUBLISHED))
			}
		}
		private function closePlayBack():void{bufferTimer.stop();this.clear();pstream.close();this.attachCamera(yourCam);}
		
		
		public function onMetaData(param=null):void{}
		public function onPlayStatus(param=null):void{}
		public function previewRecording( value:String="test" ){this.attachNetStream(pstream);pstream.play(value);}

		public function pauseRecording(){state="append"; _recordedTime = mediaPosition; stream.close();startTrackProgress(false);closePlayBack()}
		public function resetRecording(){state="record";_recordedTime = 0;stream.publish("null");startTrackProgress(false);closePlayBack();stream = new NetStream(connection);stream.client = this;}
		
		public function set fmsHost(value:String):void{_fmsHost = value;}
		public function get fmsHost():String{return _fmsHost;}
		
		public function set mediaDuration(value:Number):void{_mediaDuration = value;}
		public function get mediaDuration():Number{return _mediaDuration;}
		
	}
	
}
