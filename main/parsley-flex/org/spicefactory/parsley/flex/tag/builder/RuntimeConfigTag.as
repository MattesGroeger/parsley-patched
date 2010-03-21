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

package org.spicefactory.parsley.flex.tag.builder {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.ConfigurationProcessor;
import org.spicefactory.parsley.core.registry.ObjectDefinitionFactory;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;
import org.spicefactory.parsley.runtime.processor.RuntimeConfigurationProcessor;
import org.spicefactory.parsley.tag.RootConfigurationTag;

[DefaultProperty("instances")]

/**
 * MXML tag for adding runtime instance to the configuration of a Context.
 * 
 * <p>Example:</p>
 * 
 * <pre><code>&lt;parsley:ContextBuilder&gt;
 *     &lt;parsley:FlexConfig type="{BookStoreConfig}"/&gt;
 *     &lt;parsley:RuntimeConfig instances="{[instance1, instance2]}"/&gt;
 * &lt;/parsley:ContextBuilder&gt;</code></pre> 
 * 
 * <p>or with ids:</p>
 * 
 * <pre><code>&lt;parsley:ContextBuilder&gt;
 *     &lt;parsley:FlexConfig type="{BookStoreConfig}"/&gt;
 *     &lt;parsley:RuntimeConfig "&gt;
 *         &lt;parsley:Instance instance="{instance1}" id="id1"/&gt;
 *         &lt;parsley:Instance instance="{instance2}" id="id2"/&gt;
 *     &lt;/parsley:RuntimeConfig "&gt;
 * &lt;/parsley:ContextBuilder&gt;</code></pre>
 * 
 * @author Jens Halm
 */
public class RuntimeConfigTag implements ContextBuilderProcessor, ConfigurationProcessor {
	
	/**
	 * The configuration artifacts to add to the Context.
	 */
	public var instances:Array;

	
	private var runtimeProcessor:RuntimeConfigurationProcessor = new RuntimeConfigurationProcessor();

	
	/**
	 * @inheritDoc
	 */
	public function processBuilder (builder:CompositeContextBuilder) : void {
		builder.addProcessor(this);
	}

	public function processConfiguration (registry:ObjectDefinitionRegistry) : void {
		for each (var instance:Object in instances) {
			if (instance is InstanceTag) {
				var tag:InstanceTag = InstanceTag(instance);
				runtimeProcessor.addInstance(tag.instance, tag.id);
			}
			else if (instance is ObjectDefinitionFactory) {
				/* TODO - ObjectDefinitionFactory is deprecated - remove in later versions */
				var definition:RootObjectDefinition 
						= ObjectDefinitionFactory(instance).createRootDefinition(registry);
				registry.registerDefinition(definition);
			}
			else if (instance is RootConfigurationTag) {
				RootConfigurationTag(instance).process(registry);
			}
			else {
				var ci:ClassInfo = ClassInfo.forInstance(instance, registry.domain);
				var idProp:Property = ci.getProperty("id");
				var id:String = (idProp == null) ? null : idProp.getValue(instance);
				runtimeProcessor.addInstance(instance, id);
			}
		}
		runtimeProcessor.processConfiguration(registry);
	}
	
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "RuntimeConfig{" + instances.length + " instance(s)}";
	}
	
	
}
}