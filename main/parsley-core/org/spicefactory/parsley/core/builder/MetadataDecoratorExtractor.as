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
import org.spicefactory.parsley.core.metadata.Target;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;
import org.spicefactory.parsley.factory.decorator.AsyncInitDecorator;
import org.spicefactory.parsley.factory.decorator.FactoryMethodDecorator;
import org.spicefactory.parsley.factory.decorator.InjectConstructorDecorator;
import org.spicefactory.parsley.factory.decorator.InjectMethodDecorator;
import org.spicefactory.parsley.factory.decorator.InjectPropertyDecorator;
import org.spicefactory.parsley.factory.decorator.PostConstructMethodDecorator;
import org.spicefactory.parsley.factory.decorator.PreDestroyMethodDecorator;
import org.spicefactory.parsley.messaging.decorator.ManagedEventsDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageBindingDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageDispatcherDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageHandlerDecorator;
import org.spicefactory.parsley.messaging.decorator.MessageInterceptorDecorator;
import org.spicefactory.parsley.messaging.impl.Selector;
import org.spicefactory.parsley.resources.ResourceBindingDecorator;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class MetadataDecoratorExtractor {
	
	
	private static const targetPropertyMap:Dictionary = new Dictionary();
	
	private static var initialized:Boolean = false;
	
	
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
	}

	
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
			if (type is Member) {
				setTargetProperty(type as Member, decorators);
			}
			if (metadata is ObjectDefinitionDecorator) decorators.push(metadata);
		}
	}
	
	private static function setTargetProperty (member:Member, decorator:Object) : void {
		var ci:ClassInfo = ClassInfo.forInstance(decorator);
		var target:* = targetPropertyMap[ci.getClass()];
		if (target == undefined) {
			for each (var property:Property in ci.getProperties()) {
				if (property.getMetadata(Target)) {
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
