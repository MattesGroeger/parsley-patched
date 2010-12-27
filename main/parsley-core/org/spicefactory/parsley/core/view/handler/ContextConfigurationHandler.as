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

package org.spicefactory.parsley.core.view.handler {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextConfigurationEvent;
import org.spicefactory.parsley.core.view.ViewConfigurator;
import org.spicefactory.parsley.core.view.ViewHandler;
import org.spicefactory.parsley.core.view.ViewSettings;

import flash.display.DisplayObject;

/**
 * ViewHandler implementation that deals with bubbling events from ContextBuilders that need to know
 * the parent Context to use for the building process.
 * 
 * @author Jens Halm
 */
public class ContextConfigurationHandler implements ViewHandler {


	private var context:Context;
	
	
	/**
	 * @inheritDoc
	 */
	public function init (context:Context, settings:ViewSettings, configurator:ViewConfigurator) : void {
		this.context = context;
	}

	/**
	 * @inheritDoc
	 */
	public function destroy () : void {
		/* nothing to do */
	}
	
	/**
	 * @inheritDoc
	 */
	public function addViewRoot (view:DisplayObject) : void {
		view.addEventListener(ContextConfigurationEvent.CONFIGURE_CONTEXT, contextCreated);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeViewRoot (view:DisplayObject) : void {
		view.removeEventListener(ContextConfigurationEvent.CONFIGURE_CONTEXT, contextCreated);
	}
	
	private function contextCreated (event:ContextConfigurationEvent) : void {
		if (event.config.parent == null) {
			event.config.parent = context;
		}
		event.stopImmediatePropagation();
	}
	

}
}
