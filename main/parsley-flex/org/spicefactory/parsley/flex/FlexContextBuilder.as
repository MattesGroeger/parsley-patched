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
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.flex.view.RootViewManager;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class FlexContextBuilder {

	public function FlexContextBuilder () {
	}
	
	public static function build (container:Class, parent:Context = null, 
			viewTriggerEvent:String = "configureIOC", domain:ApplicationDomain = null) : Context {
		return buildAll([container], parent, viewTriggerEvent, domain);
	}
	
	public static function buildAll (containers:Array, parent:Context = null,
			viewTriggerEvent:String = "configureIOC", domain:ApplicationDomain = null) : Context {
		var context:Context = ActionScriptContextBuilder.buildAll(containers, parent, domain);
		RootViewManager.addContext(context, viewTriggerEvent, domain);
		return context;		
	}
	
	
	public static function merge (container:Class, builder:CompositeContextBuilder,
			viewTriggerEvent:String = "configureIOC") : void {
		// TODO - need context ref for deferred creation of view manager
		ActionScriptContextBuilder.merge(container, builder);
	}
	
	public static function mergeAll (containers:Array, builder:CompositeContextBuilder,
			viewTriggerEvent:String = "configureIOC") : void {
		// TODO - need context ref for deferred creation of view manager
		ActionScriptContextBuilder.mergeAll(containers, builder);
	}
	
	
}
}
