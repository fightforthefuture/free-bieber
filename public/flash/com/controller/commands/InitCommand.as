/**
 * @author 	Sameer Jain
 * @Title	Flash Developer
 * @Company	Saachi Technologies [p] Ltd
 */
package com.controller.commands
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import com.view.ApplicationMediator;
	import com.model.DataProxy;

	public class InitCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			var am:ApplicationMediator	=	facade.retrieveMediator(ApplicationMediator.NAME) as ApplicationMediator;
			var dp:DataProxy			=	facade.retrieveProxy(DataProxy.NAME) as DataProxy;
			var params					=	am.view.loaderInfo.parameters
			DataProxy.filename			=	params.filename;
			DataProxy.overlayimage		=	params.overlayimage;
			dp.loadTemplate();
		}
	}
}