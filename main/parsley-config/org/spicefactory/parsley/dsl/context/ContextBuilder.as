package org.spicefactory.parsley.dsl.context {
import org.spicefactory.parsley.config.Configuration;
import org.spicefactory.parsley.config.Configurations;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilderFactory;
import org.spicefactory.parsley.flex.FlexSupport;
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

import org.spicefactory.parsley.flex.processor.FlexConfigurationProcessor;
import org.spicefactory.parsley.runtime.processor.RuntimeConfigurationProcessor;
import org.spicefactory.parsley.xml.processor.XmlConfigurationProcessor;

/**
 * A ContextBuilder offers the option to create a new Context programmatically using the convenient
 * configuration DSL.
 * 
 * <p>A standard ContextBuilder can be created using the <code>newBuilder</code> method:</p>
 * 
 * <p><pre>ContextBuilder.newBuilder()
 *     .xmlConfig("logging.xml")
 *     .flexConfig(MyConfig)
 * 	   .build();</pre></p>
 * 	   
 * <p>If you need to specify more options than just the configuration artifacts, you must enter
 * setup mode first:</p>
 * 
 * <p><pre>var viewRoot:DisplayObject = ...;
 * var parent:Context = ...;
 * ContextBuilder.newSetup()
 *     .viewRoot(viewRoot)
 *     .parent(parent)
 *     .viewSettings().autoremoveComponents(false)
 *     .newBuilder()
 *         .xmlConfig("logging.xml")
 *         .flexConfig(MyConfig)
 * 	       .build();</pre></p>
 * 
 * @author Jens Halm
 */
public class ContextBuilder {
	
	
	/**
	 * Creates a new ContextBuilder instance applying default settings.
	 * In case you want to specify options like view root, custom scopes
	 * or parent Contexts, use <code>newSetup</code> instead.
	 * 
	 * @return a new ContextBuilder instance applying default settings
	 */
	public static function newBuilder () : ContextBuilder {
		return new ContextBuilderSetup().newBuilder();
	}
	
	/**
	 * Creates a new setup instance that allows to specify custom
	 * options for the ContextBuilder to be created.
	 * 
	 * @return a new setup instance that allows to specify custom
	 * options for the ContextBuilder to be created
	 */
	public static function newSetup () : ContextBuilderSetup {
		return new ContextBuilderSetup();
	}

	
	private var builder:CompositeContextBuilder;
	private var runtimeConfig:RuntimeConfigurationProcessor;
	private var config:Configuration;
	
	
	/**
	 * @private
	 */
	function ContextBuilder (builder:DefaultCompositeContextBuilder) {
		this.config = Configurations.forRegistry(builder.prepareRegistry());
		this.builder = builder;
		FlexSupport.initialize();
	}
	
	
	/**
	 * Adds an MXML configuration class to this builder.
	 * 
	 * @param config the MXML configuration class to add
	 * @return this builder instance for method chaining
	 */
	public function flexConfig (config:Class) : ContextBuilder {
		builder.addProcessor(new FlexConfigurationProcessor([config]));
		return this;
	}
	
	/**
	 * Adds an XML configuration file to this builder.
	 * 
	 * @param config the XML configuration file to add
	 * @return this builder instance for method chaining
	 */
	public function xmlConfig (file:String) : ContextBuilder {
		builder.addProcessor(new XmlConfigurationProcessor([file]));
		return this;
	}
	
	/**
	 * Adds a custom configuration processor to this builder.
	 * 
	 * @param processor the processor to add
	 * @return this builder instance for method chaining
	 */
	public function customConfig (processor:ConfigurationProcessor) : ContextBuilder {
		builder.addProcessor(processor);
		return this;
	}
	
	/**
	 * Adds an existing instance to the Context created by this builder.
	 * The only way to apply framework features to the target instance
	 * is metadata in this case. If you need other means of applying features
	 * to an object, consider using the <code>objectDefinition</code> method instead.
	 * 
	 * @param instance the instance to add to the Context
	 * @param id the optional id of the instance
	 * @return this builder instance for method chaining
	 */
	public function object (instance:Object, id:String = null) : ContextBuilder {
		if (!runtimeConfig) {
			runtimeConfig = new RuntimeConfigurationProcessor();
			builder.addProcessor(runtimeConfig);
		}
		runtimeConfig.addInstance(instance, id);
		return this;
	}
	
	/**
	 * Returns the factory that can be used to programmatically create new
	 * object definitions using the framework's configuration DSL.
	 * This allows for more fine-grained control of the functionality that
	 * should be applied to the target instance than using the simple shortcut of
	 * the <code>object</code> method, where all object configuration would need
	 * to be done with metadata.
	 * 
	 * @return the factory that can be used to programmatically create new object definitions
	 */
	public function objectDefinition () : ObjectDefinitionBuilderFactory {
		return config.builders;
	}
	
	/**
	 * Builds and returns the final Context instance, applying all settings
	 * specified for this builder.
	 * 
	 * @return the final Context instance
	 */
	public function build () : Context {
		return builder.build();
	}
	
	
}
}
