/**
 * @author 	Sameer Jain
 * @Title	Flash Developer
 * @Company	Saachi Technologies [p] Ltd
 */
 package com
{
	import org.puremvc.as3.patterns.facade.Facade;
	import com.controller.commands.StartupCommand;

	public class ApplicationFacade extends Facade
	{
		public static const STARTUP:String 	= "STARTUP";		
		
		public static function getInstance():ApplicationFacade
		{
			if ( ! instance )
				instance = new ApplicationFacade();
			return instance as ApplicationFacade;
		}
		
		override protected function initializeController():void
		{
			super.initializeController();
			registerCommand( STARTUP, StartupCommand ); 
		}

		public function startup( app:Application ):void
		{
			sendNotification( STARTUP, app );
		}

	}
}