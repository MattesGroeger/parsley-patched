/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.parsley.core.task {
import org.spicefactory.lib.task.SequentialTaskGroup;
import org.spicefactory.lib.task.Task;
import org.spicefactory.lib.task.TaskGroup;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class CompositeContextBuilderTask extends ContextBuilderTask {

	
	private var _builder:CompositeContextBuilder;
	private var _tasks:TaskGroup = new SequentialTaskGroup();

	
	function CompositeContextBuilderTask (parent:Context = null, domain:ApplicationDomain = null) {
		super(parent, domain);
		_builder = new CompositeContextBuilder(parent, domain);
	}
	
	
	public function get registry () : ObjectDefinitionRegistry {
		return _builder.registry;
	}
	
	
	public function addBuilderTask (t:Task) : void {
		_tasks.addTask(t);
	}
	
	
	protected override function doStart () : void {
		_tasks.addEventListener(TaskEvent.COMPLETE, tasksComplete);		
		_tasks.addEventListener(ErrorEvent.ERROR, tasksError);		
	}
	
	private function tasksComplete (event:Event) : void {
		super.doStart();
	}
	
	private function tasksError (event:ErrorEvent) : void {
		error(event.text);
	}
	
	protected override function build (parent:Context = null, domain:ApplicationDomain = null) : Context {
		return _builder.build();
	}
	
	
}

}
