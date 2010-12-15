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

package org.spicefactory.parsley.core.bootstrap {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.messaging.MessageSettings;
import org.spicefactory.parsley.core.scope.ScopeExtensionRegistry;
import org.spicefactory.parsley.core.view.ViewSettings;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

/**
 * Represents the configuration to be used to create a new Context.
 * These configurations are applied hierarchical, meaning that anything not explicitly set
 * on this instance will be fetched from the configuration of the parent Context or, in case there is
 * no parent or a particular option is not explicitly set on the parent, from <code>BootstrapDefaults.config</code>. 
 * 
 * @author Jens Halm
 */
public interface BootstrapConfig {
	
	
	/**
	 * The services to be used for creating a new Context.
	 */
	function get services () : ServiceRegistry;
	
	/**
	 * The settings for the ViewManager of the new Context. 
	 */
	function get viewSettings () : ViewSettings;
	
	/**
	 * The settings for the MessageRouter of the new Context.
	 */
	function get messageSettings () : MessageSettings;
	
	/**
	 * A registry of scope-wide extensions.
	 */
	function get scopeExtensions () : ScopeExtensionRegistry;
	
	/**
	 * The ApplicationDomain to be used for reflecting on managed objects.
	 */
	function get domain () : ApplicationDomain;
	
	function set domain (value:ApplicationDomain) : void;
	
	/**
	 * The provider to use for determining the ApplicationDomain when it is not specified explicitly.
	 */
	function get domainProvider () : ApplicationDomainProvider;
	
	function set domainProvider (value:ApplicationDomainProvider) : void;
	
	/**
	 * The parent of the new Context.
	 */
	function get parent () : Context;
	
	function set parent (value:Context) : void;
	
	/**
	 * The initial view root to be used for view wiring.
	 * Additional view roots can be added later through <code>Context.viewManager.addViewRoot()</code>.
	 */
	function get viewRoot () : DisplayObject;
	
	function set viewRoot (value:DisplayObject) : void;
	
	/**
	 * The description to use in log output for the new Context.
	 */
	function get description () : String;
	
	function set description (value:String) : void;
	
	/**
	 * Adds a custom scope to the new Context.
	 * The new scope will be added to the scopes which may be inherited from a parent Context.
	 * 
	 * @param name the name of the scope
	 * @param inherited whether child Contexts should inherit this scope
	 * @param uuid the unique id of this scope
	 */
	function addScope (name:String, inherited:Boolean = true, uuid:String = null) : void;
	
	/**
	 * Adds a configuration processor.
	 * 
	 * @param processor the processor to add
	 */
	function addProcessor (processor:ConfigurationProcessor) : void; 


}
}
