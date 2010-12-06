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
import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.parsley.core.context.Context;

import flash.events.Event;
import flash.system.ApplicationDomain;

/**
 * Event that fires when a new Context gets created that is associated with a view root.
 * 
 * @author Jens Halm
 */
public class ContextBuilderEvent extends Event {


	/**
	 * Constant for the type of bubbling event fired when a new Context gets created that is 
	 * associated with a view root. The event is used to determine the parent Context and
	 * ApplicationDomain for the new Context in case another Context already exists somewhere
	 * in the view hierarchy above the new Context.
	 * 
	 * @eventType configureView
	 */
	public static const BUILD_CONTEXT : String = "createContext";
	
	
	private var _domain:ApplicationDomain;
	private var _parent:Context;
	private var _scopes:Array = new Array();
	
	
	/**
	 * Creates a new event instance.
	 */
	public function ContextBuilderEvent () {
		super(BUILD_CONTEXT, true);
	}
	
	/**
	 * The ApplicationDomain to be used by the new Context.
	 */
	public function get domain () : ApplicationDomain {
		return _domain;
	}
	
	public function set domain (domain:ApplicationDomain) : void {
		if (_domain != null) {
			throw new IllegalStateError("ApplicationDomain has already been set for this event");
		}
		_domain = domain;
	}
	
	/**
	 * @copy org.spicefactory.parsley.core.builder.CompositeContextBuilder#addScope()
	 */
	public function addScope (name:String, inherited:Boolean = true, uuid:String = null) : void {
		_scopes.push(new Scope(name, inherited, uuid));
	}
	
	/**
	 * Adds the scopes specified for this event to the builder.
	 * 
	 * @param builder the builder to add the scopes to
	 */
	public function processScopes (config:BootstrapConfig) : void {
		for each (var s:Scope in _scopes) {
			config.addScope(s.name, s.inherited, s.uuid);
		}
	}
	
	/**
	 * The Context to be used as the parent for the new Context.
	 */
	public function get parent () : Context {
		return _parent;
	}
	
	public function set parent (parent:Context) : void {
		if (_parent != null) {
			throw new IllegalStateError("Parent Context has already been set for this event");
		}
		_parent = parent;
	}	
	
	
	/**
	 * @private
	 */
	public override function clone () : Event {
		var cbe:ContextBuilderEvent = new ContextBuilderEvent();
		cbe.domain = domain;
		cbe.parent = parent;
		return cbe;
	}		
	
	
}
}

class Scope {
	
	public var name:String;
	public var inherited:Boolean;
	public var uuid:String;
	
	function Scope (name:String, inherited:Boolean, uuid:String) {
		this.name = name;
		this.inherited = inherited;
		this.uuid = uuid;
	}
	
}
