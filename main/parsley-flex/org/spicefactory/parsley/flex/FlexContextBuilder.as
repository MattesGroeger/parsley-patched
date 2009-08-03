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

package org.spicefactory.parsley.flex {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.flex.FlexLogFactory;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.builder.ActionScriptObjectDefinitionBuilder;
import org.spicefactory.parsley.flex.resources.FlexResourceBindingAdapter;
import org.spicefactory.parsley.flex.view.RootViewManager;
import org.spicefactory.parsley.resources.ResourceBindingDecorator;

import flash.system.ApplicationDomain;

/**
 * Static entry point methods for building a Context from MXML configuration classes.
 * 
 * <p>For details see 
 * <a href="http://www.spicefactory.org/parsley/docs/2.0/manual?page=config&section=mxml>3.2 MXML Configuration</a>
 * in the Parsley Manual.</p>
 * 
 * <p>All methods of this class additionally initialize the Flex view wiring mechanism.</p>
 * 
 * @author Jens Halm
 */
public class FlexContextBuilder {
	
	
	ResourceBindingDecorator.adapterClass = FlexResourceBindingAdapter;


	/**
	 * Builds a Context from the specified MXML configuration class.
	 * The returned Context instance may not be fully initialized if it requires asynchronous operations.
	 * You can check its state with its <code>configured</code> and <code>initialized</code> properties.
	 * 
	 * @param configClass the class that contains the MXML configuration
	 * @param parent the parent to use for the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 * @param viewTriggerEvent the event type that Flex Components will sent when they wish to be wired to the container
	 * @return a new Context instance, possibly not fully initialized yet
	 */	
	public static function build (configClass:Class, parent:Context = null, domain:ApplicationDomain = null,
			viewTriggerEvent:String = "configureIOC") : Context {
		return buildAll([configClass], parent, domain, viewTriggerEvent);
	}
	
	/**
	 * Builds a Context from the specified MXML configuration classes.
	 * The returned Context instance may not be fully initialized if it requires asynchronous operations.
	 * You can check its state with its <code>configured</code> and <code>initialized</code> properties.
	 * 
	 * @param configClasses the classes that contains the MXML configuration
	 * @param parent the parent to use for the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 * @param viewTriggerEvent the event type that Flex Components will sent when they wish to be wired to the container
	 * @return a new Context instance, possibly not fully initialized yet
	 */	
	public static function buildAll (configClasses:Array, parent:Context = null, domain:ApplicationDomain = null,
			viewTriggerEvent:String = "configureIOC") : Context {
		var builder:CompositeContextBuilder = new CompositeContextBuilder(parent, domain);
		mergeAll(configClasses, builder, viewTriggerEvent);
		return builder.build();		
	}
	
	
	/**
	 * Merges the specified MXML configuration class with the specified composite builder.
	 * 
	 * @param configClass the class that contains the MXML configuration to be merged into the composite builder
	 * @param builder the builder to add the configuration to
	 * @param viewTriggerEvent the event type that Flex Components will sent when they wish to be wired to the container
	 * 
	 */
	public static function merge (configClass:Class, builder:CompositeContextBuilder,
			viewTriggerEvent:String = "configureIOC") : void {
		mergeAll([configClass], builder, viewTriggerEvent);
	}

	/**
	 * Merges the specified MXML configuration classes with the specified composite builder.
	 * 
	 * @param configClasses the classes that contain the MXML configuration to be merged into the composite builder
	 * @param builder the builder to add the configuration to
	 * @param viewTriggerEvent the event type that Flex Components will sent when they wish to be wired to the container
	 * 
	 */
	public static function mergeAll (configClasses:Array, builder:CompositeContextBuilder,
			viewTriggerEvent:String = "configureIOC") : void {
		RootViewManager.addContext(builder.context, viewTriggerEvent, builder.domain);
		if (LogContext.factory == null) LogContext.factory = new FlexLogFactory();
		builder.addBuilder(new ActionScriptObjectDefinitionBuilder(configClasses));
	}


}
}