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

package org.spicefactory.parsley.core.state.manager {
import flash.system.ApplicationDomain;

/**
 * Manages the ApplicationDomain instances associated with all currently active Context instances.
 * If an ApplicationDomain is no longer in use after the last Context associated with it gets destroyed,
 * the reflection cache for that domain can be purged.
 * 
 * <p>This manager is usually only exposed to the IOC kernel services and can be accessed through a <code>BootstrapInfo</code>
 * instance.</p>
 * 
 * @author Jens Halm
 */
public interface GlobalDomainManager {
	
	
	/**
	 * Adds a handler to be invoked when an ApplicationDomain is no longer used by any Context.
	 * 
	 * @param domain the domain to watch
	 * @param handler the function to invoke in case the domain is no longer in use
	 * @param params any parameters that should be passed to the handler in addition to the domain itself
	 */
	function addPurgeHandler (domain:ApplicationDomain, handler:Function, ...params) : void;
	
	
}
}
