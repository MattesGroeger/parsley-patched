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

package org.spicefactory.parsley.core.builder {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Member;
import org.spicefactory.lib.reflect.Metadata;
import org.spicefactory.lib.reflect.MetadataAware;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.metadata.InternalProperty;
import org.spicefactory.parsley.core.metadata.ObjectDefinitionMetadata;
import org.spicefactory.parsley.core.metadata.Target;
import org.spicefactory.parsley.messaging.decorator.ManagedEventsDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageBindingDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageDispatcherDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageHandlerDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageInterceptorDecorator;
import org.spicefactory.parsley.messaging.impl.Selector;
import org.spicefactory.parsley.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.registry.decorator.AsyncInitDecorator;
import org.spicefactory.parsley.registry.decorator.FactoryMethodDecorator;
import org.spicefactory.parsley.registry.decorator.InjectConstructorDecorator;
import org.spicefactory.parsley.registry.decorator.InjectMethodDecorator;
import org.spicefactory.parsley.registry.decorator.InjectPropertyDecorator;
import org.spicefactory.parsley.registry.decorator.PostConstructMethodDecorator;
import org.spicefactory.parsley.registry.decorator.PreDestroyMethodDecorator;
import org.spicefactory.parsley.resources.ResourceBindingDecorator;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Static Utility method that can be used by all object definiton builders that wish to process
 * metadata tags on classes. All builtin configuration mechanisms (MXML, XML and ActionScript)
 * use this method.
 * 
 * @author Jens Halm
 */
public class MetadataDecoratorExtractor {
	
	
	private static const targetPropertyMap:Dictionary = new Dictionary();
	
	private static var initialized:Boolean = false;
	
	
	/**
	 * Initializes the metadata tag registrations for all builtin metadata tags.
	 * Will be called by all the builtin ContextBuilder entry point methods
	 * and usually does not need to be called by an application.
	 */
	public static function initialize (domain:ApplicationDomain) : void {
		if (initialized) return;
		initialized = true;
		
		Metadata.registerMetadataClass(InjectConstructorDecorator, domain);
		Metadata.registerMetadataClass(InjectPropertyDecorator, domain);
		Metadata.registerMetadataClass(InjectMethodDecorator, domain);
		Metadata.registerMetadataClass(FactoryMethodDecorator, domain);
		Metadata.registerMetadataClass(PostConstructMethodDecorator, domain);
		Metadata.registerMetadataClass(PreDestroyMethodDecorator, domain);
		Metadata.registerMetadataClass(AsyncInitDecorator, domain);
		
		Metadata.registerMetadataClass(ManagedEventsDecorator, domain);
		Metadata.registerMetadataClass(MessageDispatcherDecorator, domain);
		Metadata.registerMetadataClass(MessageHandlerDecorator, domain);
		Metadata.registerMetadataClass(MessageBindingDecorator, domain);
		Metadata.registerMetadataClass(MessageInterceptorDecorator, domain);
		
		Metadata.registerMetadataClass(ResourceBindingDecorator, domain);

		Metadata.registerMetadataClass(Selector, domain);
		Metadata.registerMetadataClass(Target, domain);
		
		Metadata.registerMetadataClass(InternalProperty, domain);
		Metadata.registerMetadataClass(ObjectDefinitionMetadata, domain);
	}


	/**
	 * Extracts the metadata configuration for the specified class.
	 * The returned array contains instances of the <code>ObjectDefinitionDecorator</code> interface.
	 * 
	 * @param type the class to extract all decorator tags from
	 * @return the metadata configuration for the specified class
	 */	
	public static function extract (type:ClassInfo) : Array {
		var decorators:Array = new Array();
		extractMetadataDecorators(type, decorators);
		for each (var property:Property in type.getProperties()) {
			extractMetadataDecorators(property, decorators);
		}
		for each (var method:Method in type.getMethods()) {
			extractMetadataDecorators(method, decorators);
		}
		return decorators;
	}

	private static function extractMetadataDecorators (type:MetadataAware, decorators:Array) : void {
		for each (var metadata:Object in type.getAllMetadata()) {
			if (metadata is ObjectDefinitionDecorator) {
				if (type is Member) {
					setTargetProperty(type as Member, metadata);
				}
				decorators.push(metadata);
			}
		}
	}
	
	private static function setTargetProperty (member:Member, decorator:Object) : void {
		var ci:ClassInfo = ClassInfo.forInstance(decorator);
		var target:* = targetPropertyMap[ci.getClass()];
		if (target == undefined) {
			for each (var property:Property in ci.getProperties()) {
				if (property.getMetadata(Target).length > 0) {
					if (!property.writable) {
						target = new Error(property.toString() + " was marked with [Target] but is not writable");
					}
					else if (!property.type.isType(String)) {
						target = new Error(property.toString() + " was marked with [Target] but is not of type String");
					}
					else {
						target = property;
					}
					break; 
				}
			}
			if (target == null) {
				target = new Error("No property marked with [Target] in ObjectDefinitionDecorator class " + ci.name);
			}
			// we also cache errors so we do not process the same class twice
			targetPropertyMap[ci.getClass()] = target;
		}
		if (target is Property) {
			Property(target).setValue(decorator, member.name);
		}
		else {
			throw new ContextError(Error(target).message);
		}					
	}
	
	
}
}
