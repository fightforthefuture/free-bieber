/**
 * @author 	Sameer Jain
 * @Title	Flash Developer
 * @Company	Saachi Technologies [p] Ltd
 */
 
package com.controller.commands
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import com.Application;
	import com.view.ApplicationMediator;

	public class PrepViewCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			//register mediators
			var app:Application = note.getBody() as Application;
			facade.registerMediator( new ApplicationMediator( app ) );
			//register our header view
		}
		
	}
}