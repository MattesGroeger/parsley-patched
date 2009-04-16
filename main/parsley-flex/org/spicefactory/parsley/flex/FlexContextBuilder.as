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
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.builder.ActionScriptObjectDefinitionBuilder;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class FlexContextBuilder {

	
	public static function build (container:Class, parent:Context = null, domain:ApplicationDomain = null,
			viewTriggerEvent:String = "configureIOC") : Context {
		return buildAll([container], parent, domain, viewTriggerEvent);
	}
	
	public static function buildAll (containers:Array, parent:Context = null, domain:ApplicationDomain = null,
			viewTriggerEvent:String = "configureIOC") : Context {
		var builder:FlexCompositeContextBuilder = new FlexCompositeContextBuilder(viewTriggerEvent, parent, domain);
		mergeAll(containers, builder);
		return builder.build();		
	}
	
	
	public static function merge (container:Class, builder:FlexCompositeContextBuilder) : void {
		mergeAll([container], builder);
	}

	public static function mergeAll (containers:Array, builder:FlexCompositeContextBuilder) : void {
		builder.addBuilder(new ActionScriptObjectDefinitionBuilder(containers));
	}


}
}