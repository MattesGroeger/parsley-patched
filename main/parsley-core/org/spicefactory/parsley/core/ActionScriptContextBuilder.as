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
import org.spicefactory.parsley.core.builder.ActionScriptObjectDefinitionBuilder;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class ActionScriptContextBuilder {
	
	
	public static function build (container:Class, parent:Context = null, domain:ApplicationDomain = null) : Context {
		return buildAll([container], parent, domain);		
	}
	
	public static function buildAll (containers:Array, parent:Context = null, domain:ApplicationDomain = null) : Context {
		var builder:CompositeContextBuilder = new CompositeContextBuilder(parent, domain);
		mergeAll(containers, builder);
		return builder.build();
	}
	
	
	public static function merge (container:Class, builder:CompositeContextBuilder) : void {
		mergeAll([container], builder);
	}
	
	public static function mergeAll (containers:Array, builder:CompositeContextBuilder) : void {
		builder.addBuilder(new ActionScriptObjectDefinitionBuilder(containers));
	}
	
	
}
}

