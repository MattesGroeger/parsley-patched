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

package org.spicefactory.parsley.tag.lifecycle {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.ObjectLifecycleListener;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.tag.util.DecoratorUtil;

[Metadata(name="PostConstruct", types="method")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on methods that should be invoked after
 * the object has been created and fully configured.
 *
 * <p>This <code>ObjectDefinitionDecorator</code> adds itself to the processed definiton as an <code>ObjectLifecycleListener</code>,
 * thus both interfaces are implemented.</p>
 * 
 * @author Jens Halm
 */
public class PostConstructMethodDecorator implements ObjectDefinitionDecorator, ObjectLifecycleListener {


	[Target]
	/**
	 * The name of the method.
	 */
	public var method:String;
	
	
	private var targetMethod:Method;	

	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		targetMethod = DecoratorUtil.getMethod(method, definition);
		definition.lifecycleListeners.addLifecycleListener(this);
		return definition;
	}
	
	/**
	 * @inheritDoc
	 */
	public function postConstruct (instance:Object, context:Context) : void {
		targetMethod.invoke(instance, []);
	}
	
	/**
	 * @inheritDoc
	 */
	public function preDestroy (instance:Object, context:Context) : void {
		/* nothing to do here */
	}
	
}
}
