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

package org.spicefactory.parsley.flex.view {
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.factory.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.parsley.flex.view.AbstractViewManager;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class ModuleViewManager extends AbstractViewManager {
	
	
	private var context:FlexViewContext;
	private var container:DisplayObject;
	

	public function ModuleViewManager (container:DisplayObject, triggerEventType:String = null) {
		super(triggerEventType);
		this.container = container;
	}

	
	public function init (parent:Context, domain:ApplicationDomain) : void {
		context = new FlexViewContext(parent, new DefaultObjectDefinitionRegistry(domain));
		addListener(container);
		// TODO - listen for ContextEvent.DESTROYED
	}
	
	protected override function getContext (component:DisplayObject) : FlexViewContext {
		return context;
	}
	
	
}

}
