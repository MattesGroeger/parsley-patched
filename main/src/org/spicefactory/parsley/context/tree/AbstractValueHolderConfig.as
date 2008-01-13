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
 
package org.spicefactory.parsley.context.tree {
import org.spicefactory.parsley.context.tree.namespaces.template.nested.ApplyFactoryTemplateConfig;
import org.spicefactory.lib.reflect.converter.BooleanConverter;
import org.spicefactory.lib.reflect.converter.ClassConverter;
import org.spicefactory.lib.reflect.converter.DateConverter;
import org.spicefactory.lib.reflect.converter.IntConverter;
import org.spicefactory.lib.reflect.converter.NumberConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.reflect.converter.UintConverter;
import org.spicefactory.parsley.context.converter.SimpleArrayConverter;
import org.spicefactory.parsley.context.tree.core.DefaultObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.DelegatingNestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.core.NestedObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.namespaces.template.nested.ApplyValueChildrenConfig;
import org.spicefactory.parsley.context.tree.values.ApplicationContextRefConfig;
import org.spicefactory.parsley.context.tree.values.ArrayConfig;
import org.spicefactory.parsley.context.tree.values.CustomValueConfig;
import org.spicefactory.parsley.context.tree.values.ListConfig;
import org.spicefactory.parsley.context.tree.values.MessageConfig;
import org.spicefactory.parsley.context.tree.values.NullValueConfig;
import org.spicefactory.parsley.context.tree.values.ReferenceConfig;
import org.spicefactory.parsley.context.tree.values.SimpleArrayConfig;
import org.spicefactory.parsley.context.tree.values.SimpleValueConfig;
import org.spicefactory.parsley.context.tree.values.StaticPropertyRefConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;

/**
 * Abstract base class for all configuration classes that accept the standard
 * value tags like <code>&lt;boolean&gt;</code> or <code>&lt;string&gt;</code> as
 * child nodes.
 * 
 * @author Jens Halm
 */
public class AbstractValueHolderConfig extends AbstractElementConfig {
	

	/**
	 * Adds all standard <code>ValueConfig</code> implementations to the 
	 * specified <code>ElementProcessor</code>.
	 * 
	 * @param ep the <code>ElementProcessor</code> to add child node configurations to
	 */
	protected function addValueConfigs (ep:DefaultElementProcessor) : void {
		ep.addChildNode("null", NullValueConfig, [], 0);
		ep.addChildNode("boolean", SimpleValueConfig, [BooleanConverter.INSTANCE], 0);
		ep.addChildNode("int", SimpleValueConfig, [IntConverter.INSTANCE], 0);
		ep.addChildNode("uint", SimpleValueConfig, [UintConverter.INSTANCE], 0);
		ep.addChildNode("number", SimpleValueConfig, [NumberConverter.INSTANCE], 0);
		ep.addChildNode("string", SimpleValueConfig, [StringConverter.INSTANCE], 0);
		ep.addChildNode("date", SimpleValueConfig, [DateConverter.INSTANCE], 0);
		ep.addChildNode("string-array", SimpleArrayConfig, [new SimpleArrayConverter(StringConverter.INSTANCE)], 0);
		ep.addChildNode("number-array", SimpleArrayConfig, [new SimpleArrayConverter(NumberConverter.INSTANCE)], 0);
		ep.addChildNode("array", ArrayConfig, [], 0);
		ep.addChildNode("message", MessageConfig, [], 0);
		ep.addChildNode("static-property-ref", StaticPropertyRefConfig, [], 0);
		
		ep.addChildNode("object", DelegatingNestedObjectFactoryConfig, [DefaultObjectFactoryConfig], 0);
		ep.addChildNode("class", SimpleValueConfig, [new ClassConverter()], 0);
		ep.addChildNode("list", ListConfig, [], 0);
		ep.addChildNode("custom", CustomValueConfig, [], 0);
		ep.addChildNode("app-context", ApplicationContextRefConfig, [], 0);
		ep.addChildNode("object-ref", ReferenceConfig, [], 0);
		
		ep.addChildNode("apply-children", ApplyValueChildrenConfig, [], 0);
		ep.addChildNode("apply-factory-template", ApplyFactoryTemplateConfig, [], 0);
		
		ep.permitCustomNamespaces(NestedObjectFactoryConfig);
	}



}

}