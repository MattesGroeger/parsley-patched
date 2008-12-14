/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.localization.spi {
	import org.spicefactory.lib.task.TaskGroup;
	import org.spicefactory.parsley.localization.Locale;
	import org.spicefactory.parsley.localization.ResourceManager;	

	/**	
 * Service provider interface that extends the public <code>LocaleManager</code> interface.
 * 
 * @author Jens Halm
 */
public interface ResourceManagerSpi extends ResourceManager {
	
	/**
	 * Initializes the <code>LocaleManager</code>. Will be called once at application startup when
	 * the first Parsley <code>ApplicationContext</code> is initialized.
	 * 
	 * @param loc the initial <code>Locale</code> to use.
	 */	
	function initialize (loc:Locale = null) : void ;

	/**
	 * The default <code>MessageBundle</code> for this instance.
	 */
	function get defaultBundle () : ResourceBundleSpi;
	
	function set defaultBundle (bundle:ResourceBundleSpi) : void;
	
	/**
	 * Adds a message bundle to this instance.
	 * 
	 * @param bundle the message bundle to add to this instance
	 */
	function addBundle (bundle:ResourceBundleSpi) : void;
	
	/**
	 * Adds a child <code>MessageSourceSpi</code> instance.
	 * This usually corresponds to the parent-child hierarchy of <code>ApplicationContext</code>
	 * instances.
	 * 
	 * @param ms the message source to add as a child
	 */
	function addChild (ms:ResourceManagerSpi) : void ;

	/**
	 * The parent <code>MessageSourceSpi</code> instance.
	 * This usually corresponds to the parent-child hierarchy of <code>ApplicationContext</code>
	 * instances.
	 */	
	function get parent () : ResourceManagerSpi ;
	
	function set parent (ms:ResourceManagerSpi) : void ;
	
	/**
	 * Invoked when the current <code>Locale</code> is switched.
	 * The implementation is expected to add the Tasks required to load all bundles for the
	 * new <code>Locale</code> to the specified <code>TaskGroup</code>.
	 * 
	 * @param loc the next active <code>Locale</code>
	 * @param group a TaskGroup to add the Tasks required to load all bundles to
	 */
	function addBundleLoaders (loc : Locale, group : TaskGroup) : void;

	/**
	 * Called when the <code>ApplicationContext</code> this message source belongs to gets
	 * destroyed. Implementations should remove all references to any loaded message bundles
	 * when this method is invoked.
	 */
	function destroy () : void;	
	
}
	
}