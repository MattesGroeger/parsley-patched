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

package org.spicefactory.parsley.core {
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.core.impl.DefaultContext;
import org.spicefactory.parsley.core.impl.MetadataObjectDefinitionReader;
import org.spicefactory.parsley.core.metadata.InternalProperty;
import org.spicefactory.parsley.core.metadata.ObjectDefinitionMetadata;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class ActionScriptContextBuilder {
	
	
	public static function build (container:Class, parent:Context = null, domain:ApplicationDomain = null) : Context {
		return buildAll([container], parent, domain);		
	}
	
	public static function buildAll (containers:Array, parent:Context = null, domain:ApplicationDomain = null) : Context {
		var registry:ObjectDefinitionRegistry = new DefaultObjectDefinitionRegistry(domain);
		populateRegistry(containers, registry);
		// TODO - handle parent
		var dc:DefaultContext = new DefaultContext(registry);
		dc.initialize();
		return dc;		
	}
	
	
	public static function merge (container:Class, builder:CompositeContextBuilder) : void {
		populateRegistry([container], builder.registry);
	}
	
	public static function mergeAll (containers:Array, builder:CompositeContextBuilder) : void {
		populateRegistry(containers, builder.registry);
	}
	
	
	private static function populateRegistry (containers:Array, registry:ObjectDefinitionRegistry = null) : void {
		for each (var container:Class in containers) {
			var ci:ClassInfo = ClassInfo.forClass(container);
			var containerDefinition:RootObjectDefinition = MetadataObjectDefinitionReader.newRootDefinition(registry, container);
			for each (var property:Property in ci.getProperties()) {
				var internalMeta:Array = property.getMetadata(InternalProperty);
				if (internalMeta.length == 0) {
					var definitionMetaArray:Array = property.getMetadata(ObjectDefinitionMetadata);
					var definitionMeta:ObjectDefinitionMetadata = (definitionMetaArray > 0) ? 
							ObjectDefinitionMetadata(definitionMetaArray[0]) : null;
					var id:String = (definitionMeta != null) ? definitionMeta.id : property.name;
					var lazy:Boolean = (definitionMeta != null) ? definitionMeta.lazy : true;
					var singleton:Boolean = (definitionMeta != null) ? definitionMeta.singleton : true;
					MetadataObjectDefinitionReader.newRootDefinition(registry, property.type.getClass(), id, lazy, singleton);
				} 
			}	
		}
	}
	
	
}

}
