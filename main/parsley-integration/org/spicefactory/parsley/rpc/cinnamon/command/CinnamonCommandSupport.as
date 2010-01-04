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

package org.spicefactory.parsley.rpc.cinnamon.command {
import org.spicefactory.cinnamon.service.ServiceRequest;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.flex.tag.builder.ContextBuilderProcessor;

/**
 * Provides a static method to initalize the support for command methods that
 * execute Cinnamon remote calls and return a ServiceRequest instance.
 * Can be used as a child tag of a <ContextBuilder> tag in MXML alternatively.
 * Since Parsley does not have any hard dependencies on Cinnamon Remoting, 
 * this support must be explicitly initialized (unless the special Pimento
 * or Cinnamon configuration tags are used which automatically initialize
 * the command support).
 * 
 * @author Jens Halm
 */
public class CinnamonCommandSupport implements ContextBuilderProcessor {

	
	private static var initialized:Boolean = false;
	
	
	/**
	 * Initializes the support for command methods that
 	 * execute Cinnamon remote calls.
	 * Must be invoked before the first Context is built.
	 */
	public static function initialize () : void {
		if (initialized) return;
		GlobalFactoryRegistry.instance.messageRouter.addCommandFactory(ServiceRequest, new CinnamonCommandFactory());
		initialized = true;
	}
	
	/**
	 * @private
	 */
	public function processBuilder (builder:CompositeContextBuilder) : void {
		initialize();
	}
	
}
}
