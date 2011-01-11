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
 
package org.spicefactory.parsley.core.events {
import flash.display.DisplayObject;
import flash.events.Event;

/**
 * Event that fires when a view component wishes to get added to the IOC container.
 * 
 * @author Jens Halm
 */
public class ViewConfigurationEvent extends Event {


	/**
	 * Constant for the type of bubbling event fired when a view component wishes to get 
	 * added to the IOC container that is associated with the nearest parent in the view hierarchy.
	 * 
	 * @eventType configureView
	 */
	public static const CONFIGURE_VIEW : String = "configureView";
	
	
	private var explicitTargets:Array;
	private var explicitConfigId:String;
	
	private var _processed:Boolean;
	
	
	/**
	 * Creates a new event instance.
	 * 
	 * @param target the target that should be wired to the container
	 * @param configId the id to use to lookup a matching configuration in the container
	 */
	public function ViewConfigurationEvent (targets:Array = null, configId:String = null) {
		super(CONFIGURE_VIEW, true);
		this.explicitTargets = targets;
		this.explicitConfigId = configId;
	}		
	
	/**
	 * The target that should be wired to the container.
	 */
	public function get configTargets () : Array {
		return (explicitTargets == null) ? [target] : explicitTargets;
	}
	
	/**
	 * Returns the id to use to lookup a matching configuration in the container
	 * for the specified target instance.
	 * If the value is null, then no container configuration will be used 
	 * and only metadata on the target instance will be processed.
	 */
	public function getConfigId (configTarget:Object) : String {
		return (explicitConfigId != null) ? explicitConfigId : 
			(configTarget is DisplayObject) ? DisplayObject(configTarget).name : null;
	}
	
	/**
	 * Indicates whether this event instance has already been processed by a Context.
	 */
	public function get processed () : Boolean {
		return _processed;
	}
	
	/**
	 * Marks this event instance as processed by a corresponding Context.
	 */
	public function markAsProcessed () : void {
		_processed = true;
	}
	
	
	/**
	 * @private
	 */
	public override function clone () : Event {
		return new ViewConfigurationEvent(explicitTargets, explicitConfigId);
	}	
		
		
}
	
}