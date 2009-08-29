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

package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Parameter;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.errors.ObjectDefinitionBuilderError;
import org.spicefactory.parsley.core.messaging.MessageTarget;
import org.spicefactory.parsley.core.messaging.impl.MessageTargetProxyManager;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.definition.ObjectLifecycleListener;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionFactory;

[Metadata(name="MessageHandler", types="method")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on methods which wish to handle messages
 * dispatched through Parsleys central message router.
 * 
 * <p>This <code>ObjectDefinitionDecorator</code> adds itself to the processed definiton as an <code>ObjectLifecycleListener</code>,
 * thus both interfaces are implemented.</p>
 *
 * @author Jens Halm
 */
public class MessageHandlerDecorator extends AbstractMessageTargetDecorator implements ObjectDefinitionDecorator, ObjectLifecycleListener {


	/**
	 * The type of the messages the target method wishes to handle.
	 */
	public var type:Class;

	/**
	 * An optional selector value to be used in addition to selecting messages by type.
	 * Will be checked against the value of the property in the message marked with <code>[Selector]</code>
	 * or against the event type if the message is an event and does not have a selector property specified explicitly.
	 */
	public var selector:String;
	
	/**
	 * Optional list of names of properties of the message that should be used as method parameters
	 * instead passing the message itself as a parameter.
	 */
	public var messageProperties:Array;

	/**
	 * Indicates whether matching messages can trigger instance creation. The default is false.
	 * <p>If this property is set to false, the object has to be created by some other means
	 * before it becomes a valid message handler. This includes being explicitly fetched from
	 * the Context, being needed as a dependency of another object or simply being configured as 
	 * a non-lazy singleton (which is the default setting).</p>
	 * <p>If this property is set to true, a proxy will be registered with the MessageRouter.
	 * Whenever a matching message is dispatched the proxy will fetch the real target from
	 * the Context. For an object configured with <code>singleton="false"</code> this means
	 * that a new instance will be created each time a matching message gets dispatched.
	 * For a lazy singleton it means that the singleton will be created at the time the
	 * first matching message gets dispatched. For non-lazy singletons setting this property
	 * does not make any difference.</p>
	 * <p>This property can only be set to true for root object definitions. For inline
	 * object definitions the framework will throw an Error if it is set to true.</p>
	 */
	public var createInstance:Boolean = false;
	
	[Target]
	/**
	 * The name of the method that wishes to handle the message.
	 */
	public var method:String;
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		domain = registry.domain;
		if (createInstance) {
			registerProxy(definition, registry);
		}
		else {
			definition.lifecycleListeners.addLifecycleListener(this);
		}
		return definition;
	}
	
	/**
	 * @inheritDoc
	 */
	public function postConstruct (instance:Object, context:Context) : void {
		var target:MessageTarget = context.messageRouter.registerMessageHandler(instance, method, 
				type, messageProperties, selector, domain);
		addTarget(instance, target);
	}
	
	
	/**
	 * Temporary solution. Impl will be different in 2.1.
	 */
	private function registerProxy (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : void {
		if (!(definition is RootObjectDefinition)) {
			throw new ObjectDefinitionBuilderError("For inline object definitions the createInstance property" +
					" cannot be set to true");
			
		}
		if (messageProperties != null) {
			throw new ObjectDefinitionBuilderError("createInstance and messageProperties attributes cannot be" +
					" combined in this release");
		}	
		if (registry.getDefinitionCount(MessageTargetProxyManager) == 0) {
			var factory:ObjectDefinitionFactory = new DefaultObjectDefinitionFactory(MessageTargetProxyManager);
			var managerDef:RootObjectDefinition = factory.createRootDefinition(registry);
			registry.registerDefinition(managerDef);
			managerDef.properties.addValue("proxies", []);
		}
		var def:ObjectDefinition = registry.getDefinitionByType(MessageTargetProxyManager);
		var proxies:Array = def.properties.getValue("proxies");
		var methodRef:Method = definition.type.getMethod(method);
		var messageType:Class = (type == null) ? Parameter(methodRef.parameters[0]).type.getClass() : type;
		proxies.push(new MessageHandlerProxy(RootObjectDefinition(definition).id, messageType, methodRef, selector, registry.domain));
	}
	
	
}
}

import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.parsley.core.messaging.MessageTarget;

import flash.system.ApplicationDomain;

class MessageHandlerProxy {
	
	private var context:Context;
	private var id:String;
	private var messageType:Class;
	private var method:Method;
	private var selector:*;
	private var domain:ApplicationDomain;
	private var target:MessageTarget;
	
	function MessageHandlerProxy (id:String, messageType:Class, method:Method, selector:*, domain:ApplicationDomain) {
		this.id = id;
		this.messageType = messageType;
		this.method = method;
		this.selector = selector;
		this.domain = domain;
	}
	
	public function init (context:Context) : void {
		this.context = context;
		target = context.messageRouter.registerMessageHandler(this, "handleMessage", messageType, null, selector, domain);
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed); 
	}
	
	private function contextDestroyed (event:ContextEvent) : void {
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		target.unregister();
	}
	
	public function handleMessage (param1:Object = undefined, ...params) : void {
		params.unshift(param1);
		method.invoke(context.getObject(id), params);
	}
	
}


