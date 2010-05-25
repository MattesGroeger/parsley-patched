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

package org.spicefactory.parsley.dsl.context {
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * Allows to specify the options for a ContextBuilder before creating it.
 * 
 * @author Jens Halm
 */
public class ContextBuilderSetup {
	
	
	private var _viewRoot:DisplayObject;
	private var _domain:ApplicationDomain;
	private var _parent:Context;
	private var _description:String;
	private var scopes:Array = new Array();
	
	private var parts:Array = new Array();
	
	
	/**
	 * Sets the view root the target Context should use to listen for bubbling
	 * events from components below that wish to get wired to the Context.
	 * 
	 * @param viewRoot the view root for the target Context
	 * @return this builder instance for method chaining 
	 */
	public function viewRoot (viewRoot:DisplayObject) : ContextBuilderSetup {
		_viewRoot = viewRoot;
		return this;
	}
	
	/**
	 * Sets the ApplicationDomain to use for reflection.
	 * 
	 * @param domain the ApplicationDomain to use for reflection
	 * @return this builder instance for method chaining 
	 */
	public function domain (domain:ApplicationDomain) : ContextBuilderSetup {
		_domain = domain;
		return this;
	}
	
	/**
	 * Sets the parent to use for the target Context to look up shared dependencies.
	 * Will usually automatically detected in the view hierarchy and only has to be specified
	 * if this is not possible, for example when the parent Context is not associated with
	 * a view root DisplayObject.
	 * 
	 * @param parent the parent to use for the target Context to look up shared dependencies
	 * @return this builder instance for method chaining 
	 */
	public function parent (parent:Context) : ContextBuilderSetup {
		_parent = parent;
		return this;
	}
	
	/**
	 * Sets a description to be passed to the Context for logging or monitoring purposes.
	 * 
	 * @param description a description to be passed to the Context for logging or monitoring purposes
	 * @return this builder instance for method chaining 
	 */
	public function description (description:String) : ContextBuilderSetup {
		_description = description;
		return this;
	}
	
	/**
	 * Allows to specify global or local messaging settings.
	 * When the local flag is set to true, only the one Context created by this builder will 
	 * be affected, when set to false or omitted all Contexts created after this value has
	 * been set will be affected.
	 * 
	 * @param local whether only the target Context or all Contexts should be affected
	 * @return a builder that allows to specify messaging settings 
	 */
	public function messagingSettings (local:Boolean = false) : MessagingSettingsBuilder {
		var part:MessagingSettingsBuilder = new MessagingSettingsBuilder(this, local);
		addPart(part);
		return part;
	}
	
	/**
	 * Allows to specify global or local settings for view wiring.
	 * When the local flag is set to true, only the one Context created by this builder will 
	 * be affected, when set to false or omitted all Contexts created after this value has
	 * been set will be affected.
	 * 
	 * @param local whether only the target Context or all Contexts should be affected
	 * @return a builder that allows to specify settings for view wiring 
	 */
	public function viewSettings (local:Boolean = false) : ViewSettingsBuilder {
		var part:ViewSettingsBuilder = new ViewSettingsBuilder(this, local);
		addPart(part);
		return part;
	}
	
	/**
	 * Allows to specify global or local factories for the IOC kernel services.
	 * When the local flag is set to true, only the one Context created by this builder will 
	 * be affected, when set to false or omitted all Contexts created after this value has
	 * been set will be affected.
	 * 
	 * @param local whether only the target Context or all Contexts should be affected
	 * @return a builder that allows to specify factories for the IOC kernel services 
	 */
	public function factories (local:Boolean = false) : FactoryRegistryBuilder {
		var part:FactoryRegistryBuilder = new FactoryRegistryBuilder(this, local);
		addPart(part);
		return part;
	}
	
	/**
	 * Sets the ApplicationDomain to use for reflection.
	 * 
	 * @param domain the ApplicationDomain to use for reflection
	 * @return this builder instance for method chaining 
	 */
	public function scope (scope:String, inherited:Boolean = true) : ContextBuilderSetup {
		scopes.push(new Scope(scope, inherited));
		return this;
	}
	
	/**
	 * Creates a new ContextBuilder based on the settings of this setup instance.
	 * 
	 * @return a new ContextBuilder based on the settings of this setup instance
	 */
	public function newBuilder () : ContextBuilder {
		var builder:DefaultCompositeContextBuilder = new DefaultCompositeContextBuilder(_viewRoot, _parent, _domain, _description);
		for each (var scope:Scope in scopes) {
			builder.addScope(scope.name, scope.inherited);
		}
		for each (var part:SetupPart in parts) {
			part.apply(builder);
		}
		return new ContextBuilder(builder);
	}
	
	private function addPart (part:SetupPart) : void {
		parts.push(part);
	}
	
	
}
}

class Scope {

	public var name:String;
	public var inherited:Boolean;
	
	function Scope (name:String, inherited:Boolean) {
		this.name = name;
		this.inherited = inherited;
	}
	
}
