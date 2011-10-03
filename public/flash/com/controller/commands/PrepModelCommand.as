/**
 * @author 	Sameer Jain
 * @Title	Flash Developer
 * @Company	Saachi Technologies [p] Ltd
 */
package com.controller.commands
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import com.model.DataProxy;

	public class PrepModelCommand extends SimpleCommand
	{
		override public function execute(notification:INotification):void
		{
			facade.registerProxy( new DataProxy() );
		}
	}
}