/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.factory.decorator {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.factory.DecoratorUtil;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.ObjectLifecycleListener;

/**
 * @author Jens Halm
 */
[Metadata(name="PreDestroy", types="method")]
public class PreDestroyMethodDecorator implements ObjectDefinitionDecorator, ObjectLifecycleListener {

	
	[Target]
	public var method:String;
	
	
	private var targetMethod:Method;	


	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		targetMethod = DecoratorUtil.getMethod(method, definition);
		definition.lifecycleListeners.addLifecycleListener(this);
		return definition;
	}
	
	public function postConstruct (instance:Object, context:Context) : void {
		/* nothing to do here */
	}
	
	public function preDestroy (instance:Object, context:Context) : void {
		targetMethod.invoke(instance, []);
	}
	
	
}
}
