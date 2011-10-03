package com.app.utils
{
	import flash.events.EventDispatcher;
	
	public class DataEventManager extends EventDispatcher
	{
		protected static var instance:DataEventManager;
		public static const ON_POST_DATA:String = "ON_POST_DATA";
		public static const ON_LOAD_DATA:String = "ON_LOAD_DATA";
		public static const ON_LOAD_ERROR:String = "ON_LOAD_ERROR";
		/**
         * 
         * Instantiates the Singleton instance of EventManager
         * 
         */        
        public function DataEventManager(access:Private)
        {
            super(this);
            if (access == null) 
            {
                throw new Error("singleton Exception has occurred");
            }
            
            instance = this;            
        }
        
        /**
         * 
         * Determines if the singleton instance of EventManager has been instantiated, 
         * if not an instance is instantiated and returned in subsequent calls to 
         * getInstance();
         * 
         * @return Singleton instance of EventManager
         * 
         */        
        public static function getInstance():DataEventManager
        {
            if (instance == null) 
            {
               instance = new DataEventManager( new Private );
            }            
            return instance;
        }
        
        /**
         * 
         * Destroys the singleton instance of EventManager
         * 
         */        
        public static function destroyInstance():void
        {
            instance = null;
        }
        public override function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void
        {
        	super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        public override function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
        	super.removeEventListener(type, listener, useCapture);
        }
        /**
         * 
         * Dispatches an event type into the event flow with an optional associated 
         * data object
         * 
         * @param the event type
         * @param the data associated with the event type
         * 
         */        
        public function broadcast(type:String, data:Object = null):Boolean
        {
            return super.dispatchEvent( new  AbstractEvent(type, data) );
        }
    }
}

final class Private {}