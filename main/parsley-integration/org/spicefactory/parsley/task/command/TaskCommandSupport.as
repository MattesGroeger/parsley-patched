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
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.parsley.core.bootstrap.BootstrapDefaults;
import org.spicefactory.parsley.flex.tag.builder.BootstrapConfigProcessor;

/**
 * Provides a static method to initalize the support for command methods that
 * return a Task instance.
 * Can be used as a child tag of a <ContextBuilder> tag in MXML alternatively.
 * Since Parsley does not have any hard dependencies on the Spicelib
 * Task Framework, this support must be explicitly initialized.
 * 
 * @author Jens Halm
 */
public class TaskCommandSupport implements BootstrapConfigProcessor {

	
	private static var initialized:Boolean = false;
	
	
	/**
	 * Initializes the support for command methods that
 	 * return a Task instance.
	 * Must be invoked before the first Context is built.
	 */
	public static function initialize () : void {
		if (initialized) return;
		BootstrapDefaults.config.messageSettings.commandFactories.addCommandFactory(Task, new TaskCommandFactory());
		initialized = true;
	}
	
	/**
	 * @private
	 */
	public function processConfig (config:BootstrapConfig) : void {
		initialize();
	}
	
	
}
}
