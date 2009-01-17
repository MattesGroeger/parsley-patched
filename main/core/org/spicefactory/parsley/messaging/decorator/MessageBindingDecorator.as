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

package org.spicefactory.parsley.messaging.decorator {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.messaging.MessageDispatcher;
import org.spicefactory.parsley.messaging.MessageTargetDefinition;

[Metadata(name="MessageBinding", types="property")]
/**
 * @author Jens Halm
 */
public class MessageBindingDecorator implements ObjectDefinitionDecorator, MessageTargetDefinition {


	[Required]
	public var type:Class;

	public var selector:String;
	
	[Required]
	public var messageProperty:String;

	[Target]
	public var targetProperty:Property;
	
	
	private var definition:ObjectDefinition;
	
	
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : void {
		this.definition = definition;
		definition.messageTargets.addMessageTarget(this);
	}

	public function apply (targetInstance:Object, dispatcher:MessageDispatcher) : void {
		dispatcher.registerMessageBinding(targetInstance, targetProperty.name, 
				type, messageProperty, selector);
	}
	
}

}
