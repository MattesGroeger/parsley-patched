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
import org.spicefactory.parsley.core.bootstrap.BootstrapDefaults;
import org.spicefactory.parsley.core.bootstrap.BootstrapManager;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.flex.processor.FlexConfigurationProcessor;
import org.spicefactory.parsley.flex.resources.FlexResourceBindingAdapter;
import org.spicefactory.parsley.processor.resources.ResourceBindingProcessor;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * Static entry point methods for building a Context from MXML configuration classes.
 * 
 * <p>For details see 
 * <a href="http://www.spicefactory.org/parsley/docs/2.3/manual?page=config&section=mxml>3.2 MXML Configuration</a>
 * in the Parsley Manual.</p>
 * 
 * @author Jens Halm
 */
public class FlexContextBuilder {
	
	
	ResourceBindingProcessor.adapterClass = FlexResourceBindingAdapter;


	/**
	 * Builds a Context from the specified MXML configuration class.
	 * The returned Context instance may not be fully initialized if it requires asynchronous operations.
	 * You can check its state with its <code>configured</code> and <code>initialized</code> properties.
	 * 
	 * @param configClass the class that contains the MXML configuration
	 * @param viewRoot the initial view root for dynamically wiring view objects
	 * @param parent the parent to use for the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 * @return a new Context instance, possibly not fully initialized yet
	 */	
	public static function build (configClass:Class, viewRoot:DisplayObject = null, 
			parent:Context = null, domain:ApplicationDomain = null) : Context {
		return buildAll([configClass], viewRoot, parent, domain);
	}
	
	/**
	 * Builds a Context from the specified MXML configuration classes.
	 * The returned Context instance may not be fully initialized if it requires asynchronous operations.
	 * You can check its state with its <code>configured</code> and <code>initialized</code> properties.
	 * 
	 * @param configClasses the classes that contains the MXML configuration
	 * @param viewRoot the initial view root for dynamically wiring view objects
	 * @param parent the parent to use for the Context to build
	 * @param domain the ApplicationDomain to use for reflection
	 * @return a new Context instance, possibly not fully initialized yet
	 */	
	public static function buildAll (configClasses:Array, viewRoot:DisplayObject = null, 
			parent:Context = null, domain:ApplicationDomain = null) : Context {
		var manager:BootstrapManager = BootstrapDefaults.config.services.bootstrapManager.newInstance() as BootstrapManager;
		manager.config.viewRoot = viewRoot;
		manager.config.parent = parent;
		manager.config.domain = domain;
		manager.config.addProcessor(new FlexConfigurationProcessor(configClasses));
		return manager.createProcessor().process();
	}
	
	
	[Deprecated(replacement="ContextBuilder DSL")]
	public static function merge (configClass:Class, builder:CompositeContextBuilder) : void {
		mergeAll([configClass], builder);
	}

	[Deprecated(replacement="ContextBuilder DSL")]
	public static function mergeAll (configClasses:Array, builder:CompositeContextBuilder) : void {
		FlexSupport.initialize();
		builder.addProcessor(new FlexConfigurationProcessor(configClasses));
	}


}
}