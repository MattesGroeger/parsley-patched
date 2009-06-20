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

package org.spicefactory.parsley.messaging.decorator {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.messaging.MessageTarget;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Abstract base class for decorators used for message targets.
 * 
 * @author Jens Halm
 */
public class AbstractMessageTargetDecorator {
	
	
	private var targets:Dictionary = new Dictionary();
	
	/**
	 * The ApplicationDomain associated with the registry this decorator belongs to.
	 */
	protected var domain:ApplicationDomain;
	
	
	/**
	 * Adds this target to this decorator for later disposal.
	 */
	protected function addTarget (instance:Object, target:MessageTarget) : void {
		if (targets[instance] != undefined) {
			throw new IllegalArgumentError("Attempt to add more than one target for the same instance: " + instance);
		}
		targets[instance] = target;
	}
	
	private function removeTarget (instance:Object) : MessageTarget {
		if (targets[instance] == undefined) {
			throw new IllegalArgumentError("No MesssageTarget was added for the specified instance: " + instance);
		}
		var target:MessageTarget = targets[instance];
		delete targets[instance];
		return target;
	}
	
	/**
	 * @copy org.spicefactory.parsley.factory.ObjectLifecycleListener#preDestroy()
	 */
	public function preDestroy (instance:Object, context:Context) : void {
		removeTarget(instance).unregister();
	}
	
	
}
}
