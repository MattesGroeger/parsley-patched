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
 
package org.spicefactory.parsley.namespaces.mvc {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.Command;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.factory.ParserContext;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.mvc.ActionInterceptor;
import org.spicefactory.parsley.mvc.ApplicationEvent;
import org.spicefactory.parsley.mvc.FrontController;
import org.spicefactory.parsley.mvc.impl.ApplicationContextInterceptor;

/**
 * Represents the <code>interceptor</code> tag from the custom configuration namespace for the
 * MVC Framework.
 * 
 * @author Jens Halm
 */
public class InterceptorConfigProcessor extends AbstractElementConfig implements ObjectProcessorConfig {

	
	private var context:ApplicationContext;
	private var config : RootObjectFactoryConfig;

	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("event-name", StringConverter.INSTANCE, false);
			var c : Converter = new ClassInfoConverter(ClassInfo.forClass(ApplicationEvent));
			ep.addAttribute("event-class", c, false);
			ep.addAttribute("controller", StringConverter.INSTANCE, false);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function parse (node:XML, context:ApplicationContext) : void {
		super.parse(node, context);
		var activeConfig:Object = ParserContext.getActiveConfig();
		if (!(activeConfig is RootObjectFactoryConfig)) {
			throw new ConfigurationError("interceptor tag can only be used for root object configurations");
		}
		context.addInitCommand(new Command(registerInterceptor));
		this.config = activeConfig as RootObjectFactoryConfig;
		this.context = context;
	}
	
	
	private function registerInterceptor () : void {
		var eventClass:ClassInfo = getAttributeValue("eventClass") as ClassInfo;
		var eventName:String = getAttributeValue("eventName") as String;
		var controllerId:String = getAttributeValue("controller") as String;
		// TODO - 1.0.1 - early check if eventClass extends ApplicationEvent
		// TODO - 1.0.1 - check if object with specified id implements ActionInterceptor
		
		var eventType:Class = (eventClass != null) ? eventClass.getClass() : null;
		var ic:ActionInterceptor = new ApplicationContextInterceptor(context, config.id);
		var controller:FrontController;
		if (controllerId == null) {
			controller = FrontController.root;
		} else {
			controller = FrontController(context.getObject(controllerId));
		}
		controller.registerInterceptor(ic, eventType, eventName);
		context.addDestroyCommand(new Command(controller.unregisterInterceptor, [ic, eventType, eventName]));
	}

	/**
	 * @inheritDoc
	 */
	public function process (obj : Object, ci : ClassInfo, destroyCommands : CommandChain) : void {
		/* do nothing */
	}
	
}

}
