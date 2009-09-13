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

package org.spicefactory.parsley.core.factory {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.view.ViewManager;

/**
 * @author Jens Halm
 */
public interface ContextStrategyProvider {
	
	
	function init (context:Context) : void;
	
	function get registry () : ObjectDefinitionRegistry;
	
	function get lifecycleManager () : ObjectLifecycleManager;
	
	function get messageRouter () : MessageRouter;
	
	function get viewManager () : ViewManager;
	
	function get createDynamicProvider () : ContextStrategyProvider;
	
	
}
}
