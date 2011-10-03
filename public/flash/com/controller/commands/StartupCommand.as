/**
 * @author 	Sameer Jain
 * @Title	Flash Developer
 * @Company	Saachi Technologies [p] Ltd
 */

package com.controller.commands
{
	import org.puremvc.as3.patterns.command.MacroCommand;

	public class StartupCommand extends MacroCommand
	{
		override protected function initializeMacroCommand():void
		{
			addSubCommand( PrepModelCommand );
			addSubCommand( PrepViewCommand );
			addSubCommand( InitCommand );
		}		
	}
}