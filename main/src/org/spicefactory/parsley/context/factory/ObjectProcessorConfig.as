/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.context.factory {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.util.CommandChain;

/**
 * Interface to be implemented by all classes that process XML nodes that act
 * as a processor that configures instances. An example for such a node are the
 * builtin <code>&lt;property&gt;</code> or <code>&lt;init-method&gt;</code> tags 
 * but also any tag from a custom configuration
 * namespace that is responsible for configuring instances.
 * 
 * @author Jens Halm
 */
public interface ObjectProcessorConfig extends ElementConfig {
	
	/**
	 * Processes this configuration and applies it to the specified instance.
	 * 
	 * @param obj the target instance to apply the configuration for
	 * @param ci the type information for the target instance
	 * @param destroyCommands the chain to add commands to that need to be processed when
	 * the ApplicationContext gets destroyed
	 */
	function process (obj:Object, ci:ClassInfo, destroyCommands:CommandChain) : void;	
		
}

}