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

package org.spicefactory.parsley.core.scopes.impl {
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.messaging.MessageRouter;
import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;
import org.spicefactory.parsley.core.scopes.ObjectLifecycleScope;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class DefaultObjectLifecycleScope implements ObjectLifecycleScope {


	private var listeners:Dictionary = new Dictionary();
	private var router:MessageRouter;
	
	
	function DefaultObjectLifecycleScope (router:MessageRouter) {
		this.router = router;
	}


	public function addListener (type:Class, event:ObjectLifecycle, listener:Function, id:String = null) : void {
		var selector:String = (id == null) ? event.key : event.key + ":" + id;
		var target:MessageTarget = new ObjectLifecycleListener(type, selector, listener);
		var targets:Array = targets[listener];
		if (targets == null) {
			targets = new Array();
			listeners[listener] = targets;
		}
		targets.push(target);
		router.receivers.addTarget(target);
	}
	
	public function removeListener (type:Class, event:ObjectLifecycle, listener:Function, id:String = null) : void {
		var selector:String = (id == null) ? event.key : event.key + ":" + id;
		var targets:Array = listeners[listener];
		if (targets == null) {
			return;
		}
		for each (var target:MessageTarget in targets) {
			if (target.messageType == type && target.selector == selector) {
				ArrayUtil.remove(targets, target);
				router.receivers.removeTarget(target);
				if (targets.length == 0) {
					delete listeners[listener];
				}
				break;
			}
		}
	}
}
}

import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;
import org.spicefactory.parsley.core.messaging.receiver.impl.AbstractMessageReceiver;

class ObjectLifecycleListener extends AbstractMessageReceiver implements MessageTarget {
	
	private var listener:Function;
	
	function ObjectLifecycleListener (type:Class, selector:String, listener:Function) {
		super(type, selector);
		this.listener = listener;
	}
	
	public function handleMessage (message:Object) : void {
		listener(message);
	}
	
}
