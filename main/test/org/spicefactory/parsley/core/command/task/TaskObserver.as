package org.spicefactory.parsley.core.command.task {
import org.spicefactory.lib.task.Task;
import org.spicefactory.lib.task.events.TaskEvent;

import flash.events.ErrorEvent;

/**
 * @author Jens Halm
 */
public class TaskObserver {
	
	
	
	public var resultEvent:TaskEvent;
	public var resultTask:Task;
	public var resultString:String;
	public var errorEvent:ErrorEvent;
	
	public var resultCounter:int = 0;
	
	
	
	[CommandResult(selector="test1")]
	public function observeWithEventParam (event:TaskEvent) : void {
		resultEvent = event;
	}

	[CommandResult(selector="test1")]
	public function observeWithTaskParam (task:Task) : void {
		resultTask = task;
	}
	
	[CommandResult(selector="test1")]
	[CommandResult(selector="test3")]
	public function observeWithResultParam (result:String) : void {
		resultString = result;
		resultCounter++;
	}
	
	[CommandError(selector="test2")]
	public function observeWithError (event:ErrorEvent) : void {
		errorEvent = event;
	}
	
	
}
}
