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
 
package org.spicefactory.parsley.binding.decorator {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.processor.PublisherProcessor;
import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.tag.util.ReflectionUtil;

[Metadata(name="Publish", types="property")]
[XmlMapping(elementName="publish")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on properties that hold a value that
 * should be published to matching subscribers.
 * 
 * @author Jens Halm
 */
public class PublishDecorator implements ObjectDefinitionDecorator {


	/**
	 * The scope the property value is published to.
	 */
	public var scope:String;

	/**
	 * The optional id the property value is published with.
	 */
	public var objectId:String;

	[Target]
	/**
	 * The property that holds the value to publish.
	 */
	public var property:String;
	
	/**
	 * Indicates whether the value published by this property should be 
	 * added to the Context (turned into a managed object) while being
	 * published. 
	 */
    public var managed:Boolean;

	
	/**
	 * @inheritDoc
	 */
	public function decorate (builder:ObjectDefinitionBuilder) : void {
		var p:Property = ReflectionUtil.getProperty(property, builder.typeInfo, true, false);
		builder.lifecycle().processorFactory(PublisherProcessor.newFactory(p, scope, objectId, managed));
	}
	

}
}
