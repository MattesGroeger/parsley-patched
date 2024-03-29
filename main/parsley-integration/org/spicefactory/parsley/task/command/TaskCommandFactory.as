/*
 * Copyright 2010 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.spicefactory.parsley.task.command {
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.command.Command;
import org.spicefactory.parsley.core.messaging.command.CommandFactory;

/**
 * CommandFactory implementation that supports command methods that
 * return a Task instance. For a subclass of <code>ResultTask</code>
 * the result value of that class can be used in result handlers,
 * otherwise the <code>Task</code> instance itself or the corresponding
 * <code>TaskEvent</code> will be passed to result handlers, depending
 * on their parameter types.
 * 
 * @author Jens Halm
 */
public class TaskCommandFactory implements CommandFactory {

	/**
	 * @inheritDoc
	 */
	public function createCommand (returnValue:Object, message:Message) : Command {
		return new TaskCommand(Task(returnValue), message);
	}
}
}

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.task.ResultTask;
import org.spicefactory.lib.task.Task;
import org.spicefactory.lib.task.enum.TaskState;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.core.messaging.Message;
import org.spicefactory.parsley.core.messaging.command.impl.AbstractCommand;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IEventDispatcher;

class TaskCommand extends AbstractCommand {


	function TaskCommand (task:Task, message:Message) {
		super(task, message);
		task.addEventListener(TaskEvent.COMPLETE, taskComplete);
		task.addEventListener(TaskEvent.CANCEL, taskCanceled);
		task.addEventListener(ErrorEvent.ERROR, taskError);
		if (task.state == TaskState.INACTIVE) {
			task.start();
		}
		start();
	}
	
	protected function taskCanceled (event:TaskEvent) : void {
		removeEventListeners(event.target as IEventDispatcher);
		cancel();
	}
	
	private function taskComplete (event:TaskEvent) : void {
		removeEventListeners(event.target as IEventDispatcher);
		complete(event);
	}
	
	private function taskError (event:ErrorEvent) : void {
		removeEventListeners(event.target as IEventDispatcher);
		error(event);
	}
	
	private function removeEventListeners (task:IEventDispatcher) : void {
		task.removeEventListener(TaskEvent.COMPLETE, taskComplete);
		task.removeEventListener(TaskEvent.CANCEL, taskCanceled);
		task.removeEventListener(ErrorEvent.ERROR, taskError);
	}
	
	protected override function selectResultValue (result:*, targetType:ClassInfo) : * {
		if (targetType.isType(Event)) {
			return result;
		}
		var target:Object = Event(result).target;
		return (target is ResultTask && !targetType.isType(Task))
			? ResultTask(target).result
			: target;
	}
	
	protected override function selectErrorValue (result:*, targetType:ClassInfo) : * {
		return (!targetType.isType(Event))
			? Event(result).target
			: result;
	}
	
	
}
