package com.app.utils 
{
	import flash.events.Event;
	
	/**
	 * 
	 * Generic Event Object which contains a data object that is associated with 
	 * a specific event which is accessible by an event handler
	 * 
	 */
	public class AbstractEvent extends Event
	{

	    public var data:Object;
	
	    public function AbstractEvent(type:String, data:Object)
	    {
	        super(type);
	        this.data = data;
	    }
	}
}