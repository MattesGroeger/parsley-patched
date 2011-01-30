/*
 * Copyright 2011 the original author or authors.
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

package org.spicefactory.parsley.core.view.lifecycle {
import org.spicefactory.parsley.core.events.ViewLifecycleEvent;
import flash.events.EventDispatcher;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.view.ViewConfiguration;
import org.spicefactory.parsley.core.view.ViewLifecycle;
import org.spicefactory.parsley.core.view.util.StageEventFilter;

import flash.display.DisplayObject;

/**
 * Implementation of the ViewLifecycle interface that uses stage events (addedToStage and removedFromStage)
 * to demarcate the lifecycle of the target.
 * 
 * <p>This lifecycle implementation gets used per default when no custom lifecycle has been installed
 * for the type of the target and the <code>autoremoveViewRoots</code> or <code>autoremoveComponents</code>
 * is set to true (the default). The former setting is only considered for the actual view roots of a Context,
 * the latter for all other regular components.</p>
 * 
 * @author Jens Halm
 */
public class AutoremoveLifecycle extends EventDispatcher implements ViewLifecycle {
	
	
	private static const log:Logger = LogContext.getLogger(AutoremoveLifecycle);
	
	
	private var config:ViewConfiguration;
	private var context:Context;
	private var filter:StageEventFilter;
	
	
	/**
	 * @inheritDoc
	 */
	public function start (config:ViewConfiguration, context:Context) : void {
		this.config = config;
		this.context = context;
		var addedHandler:Function = (config.reuse) ? viewAdded : null;
		this.filter = new StageEventFilter(config.view, viewRemoved, addedHandler);
	}
	
	/**
	 * @inheritDoc
	 */
	public function stop () : void {
		if (filter) {
			filter.dispose();
			filter = null;	
		}
		config = null;
		context = null;
	}
	
	private function viewRemoved (view:DisplayObject) : void {
		log.debug("Autoremove view '{0}' after removal from stage", view);
		dispatchEvent(new ViewLifecycleEvent(ViewLifecycleEvent.DESTROY_VIEW, config));
	}
	
	private function viewAdded (view:DisplayObject) : void {
		log.debug("Reusable view '{0}' processed again after being added to the stage", view);
		dispatchEvent(new ViewLifecycleEvent(ViewLifecycleEvent.INIT_VIEW, config));
	}
	
	
}
}
