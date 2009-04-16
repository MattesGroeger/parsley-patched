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
import org.spicefactory.lib.reflect.MetadataAware;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.factory.ObjectDefinitionDecorator;

/**
 * @author Jens Halm
 */
public class MetadataDecoratorExtractor {
	
	
	
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
			// TODO - map Property and Method instances
			if (metadata is ObjectDefinitionDecorator) decorators.push(metadata);
		}
	}
	
	
}
}
