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
 
package org.spicefactory.parsley.context {
import flash.system.ApplicationDomain;

import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.lib.expr.impl.DefaultExpressionContext;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.util.Command;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.context.expr.ObjectFactoryVariableResolver;
import org.spicefactory.parsley.context.expr.TemplateAttributeVariableResolver;
import org.spicefactory.parsley.context.ns.context_internal;
import org.spicefactory.parsley.context.tree.core.ApplicationContextConfig;
import org.spicefactory.parsley.localization.LocaleManager;
import org.spicefactory.parsley.localization.MessageSource;
import org.spicefactory.parsley.localization.impl.DefaultLocaleManager;
import org.spicefactory.parsley.localization.impl.DefaultMessageSource;
import org.spicefactory.parsley.localization.spi.LocaleManagerSpi;
import org.spicefactory.parsley.localization.spi.MessageSourceSpi;

/**
 * The central class of the Parsley IOC Container.
 * 
 * <p>The main method for retrieving objects configured in a context is <code>getObject(String id)</code>.
 * Alternatively objects can be retrieved by type. 
 * Furthermore there are methods for retrieving information about the content of the context,
 * like the <code>objectCount</code> property or the <code>containsObject(String id)</code> method.</p>
 * 
 * <p>This class also offers access to the internationalization features of Parsley, exposing
 * the <code>LocaleManager</code> and <code>MessageSource</code> of this context and 
 * the <code>getMessage</code> method for retrieving localized messages.</p>
 * 
 * <p>A context manages the lifecycle of its content. When the <code>destroy</code> method
 * gets invoked it will in turn process all <code>&lt;destroy-method&gt;</code> tags added to
 * configured objects, unbind any message bindings and clear all references to initialized and
 * configured objects of the context factory.</p>
 * 
 * <p>For convenience there are static methods to obtain an <code>ApplicationContext</code>
 * by name or all active context instances.</p>
 * 
 * <p>To load and initialize a new <code>ApplicationContext</code> instance, you have to use
 * the <code>ApplicationContextParser</code> class. See the documentation for that class for
 * a simple example.</p>
 * 
 * @see org.spicefactory.parsley.context.ApplicationContextParser
 * 
 * @author Jens Halm
 */
public class ApplicationContext	{
	
	use namespace context_internal;
	
	private static var _logger:Logger;
	
	private var _name:String;
	
	private var _destroyed:Boolean;
	private var _destroyCommands:CommandChain;
	
	private var _initCommands:CommandChain;
	
	private var _config:ApplicationContextConfig;
	private var _parent:ApplicationContext;
	
	private var _applicationDomain:ApplicationDomain;
	private var _expressionContext:ExpressionContext;
	
	private static var _localeManager:LocaleManagerSpi;
	private static var _contextByName:SimpleMap = new SimpleMap();
	private static var _root:ApplicationContext;
	
	private var _messageSource:MessageSourceSpi;
	
	private var _underConstruction:SimpleMap; // TODO - 1.1.0 - replace with Set impl
	
	
	/**
	 * @private
	 * TODO - 1.1.0 - remove config parameter
	 */
	function ApplicationContext (name:String, config:ApplicationContextConfig = null, parent:ApplicationContext = null) {
		if (_logger == null) {
			_logger = LogContext.getLogger("org.spicefactory.parsley.context.ApplicationContext");
		}
		if (name == null || name.length == 0) {
			throw new IllegalArgumentError("name must not be null or an empty string");
		}
		if (config == null) {
			config = new ApplicationContextConfig();
		}
		_name = name;
		_destroyed = false;
		_config = config;
		_config.context = this;
		_parent = parent;
		/*
		if (_parent != null) {
			_parent.addDestroyCommand(new Command(destroy, []));
		}
		 */
		_initCommands = new CommandChain();
		_destroyCommands = new CommandChain();
		_underConstruction = new SimpleMap();
		_expressionContext = new DefaultExpressionContext();
		_expressionContext.addVariableResolver(new ObjectFactoryVariableResolver(this));
		_expressionContext.addVariableResolver(new TemplateAttributeVariableResolver());
	}
	
	/**
	 * The root <code>ApplicationContext</code>.
	 * Whether an <code>ApplicationContext</code> should be used as the root context can be
	 * specified in the constructor of an <code>ApplicationContextParser</code>.
	 * This method will only consider an instance that is fully loaded and processed but has not been
	 * destroyed yet.
	 */	
	public static function get root () : ApplicationContext {
		return _root;
	}
	
	/**
	 * Returns the <code>ApplicationContext</code> for the specified name.
	 * This method will only consider instances that are fully loaded and processed but have not been
	 * destroyed yet.
	 * 
	 * @param name the name of the ApplicationContext
	 * @return the ApplicationContext for the specified name or null if no such context exists
	 */
	public static function forName (name:String) : ApplicationContext {
		return _contextByName.get(name);
	}
	
	/**
	 * Destroys all loaded <code>ApplicationContext</code> instances.
	 */
	public static function destroyAll () : void {
		for each (var context:ApplicationContext in _contextByName.values.concat()) {
			context.destroy();
		}
	}
	
	/**
	 * Returns an Array of all active <code>ApplicationContext</code> instances.
	 * That includes all instances that are fully loaded and processed but have not been
	 * destroyed yet.
	 * 
	 * @return an Array of all active <code>ApplicationContext</code> instances
	 */
	public static function getAll () : Array {
		return _contextByName.values;
	}
	
	/**
	 * @private
	 */
	internal function initialize (useAsRoot:Boolean) : void {
		_logger.info("Initialize context with name " + _name);
		_contextByName.put(_name, this);
		if (useAsRoot) {
			_root = this;
		}
		_initCommands.execute();
		_initCommands = null;
	}
	
	/**
	 * @private
	 */
	internal function initLocaleManager () : void {
		if (_localeManager == null) {
			_localeManager = new DefaultLocaleManager();
		}
	}
	
	/**
	 * The name of this <code>ApplicationContext</code>.
	 */
	public function get name () : String {
		return _name;
	}
	
	/**
	 * The parent of this <code>ApplicationContext</code>. May be null.
	 * If this <code>ApplicationContext</code> has a parent any object lookup
	 * without a result with then delegated to the parent.
	 */
	public function get parent () : ApplicationContext {
		return _parent;
	}
	
	/**
	 * @private
	 */
	internal function setParent (value:ApplicationContext) : void {
		_parent = value;
	}
	
	/**
	 * The <code>ApplicationDomain</code> this <code>ApplicationContext</code> should use to obtain class definitions.
	 * If this property is null <code>ApplicationDomain.currentDomain</code> will be used.
	 */
	public function get applicationDomain () : ApplicationDomain {
		return _applicationDomain;
	}
	
	/**
	 * @private
	 */
	internal function setApplicationDomain (value:ApplicationDomain) : void {
		_applicationDomain = value;
	}
	
	/**
	 * The root object of the tree representing the configuration 
	 * of this <code>ApplicationContext</code>.
	 * Usually application code does not have to deal with this tree directly.
	 */
	public function get config () : ApplicationContextConfig {
		return _config;
	}
	
	/**
	 * The configuration for the expression context. This context is
	 * responsible for processing all variables like <code>${user.name}</code>
	 * that are used in configuration files.
	 */
	public function get expressionContext () : ExpressionContext {
		return _expressionContext;
	}
	
	/**
	 * The number of objects configured in this <code>ApplicationContext</code> or one
	 * of its parents.
	 */
	public function get objectCount () : uint {
		var count:uint = _config.factoryConfig.objectCount;
		return (_parent != null) ? count + _parent.objectCount : count;
	}
	
	/**
	 * The ids of all objects configured in this <code>ApplicationContext</code> or
	 * one of its parents.
	 */
	public function get objectIds () : Array {
		var ids:Array = _config.factoryConfig.objectIds;
		return (_parent != null) ? ids.concat(_parent.objectIds) : ids;
	}
	
	/**
	 * Checks whether this <code>ApplicationContext</code> contains an object configuration
	 * for the specified id. Will recursively look in parent <code>ApplicationContext</code>
	 * instances.
	 * 
	 * @param id the id of the object
	 * @return true if this <code>ApplicationContext</code> or one of its parents contains
	 * an object configuration for the specified id
	 */
	public function containsObject (id:String) : Boolean {
		var contains:Boolean =  _config.factoryConfig.containsObject(id);
		return (contains) ? true : (_parent != null) ? _parent.containsObject(id) : false;
	}

	/**
	 * Returns all object ids for the specified type (including subtypes).
	 * Will include all objects from parent <code>ApplicationContext</code> instances.
	 * 
	 * @param type the type of object to look for
	 * @return an Array containing the ids of all matching objects.
	 */	
	public function getIdsForType (type:Class) : Array {
		if (_destroyed) return null;
		var ids:Array = _config.factoryConfig.getIdsForType(type);
		if (_parent != null) {
			var parentIds:Array = _parent.getIdsForType(type);
			if (parentIds != null) {
				ids = ids.concat(parentIds);
			}
		}
		return ids;
	}
	
	
	/**
	 * Returns all objects for the specified type (including subtypes).
	 * Will include all objects from parent <code>ApplicationContext</code> instances.
	 * 
	 * @param type the type of object to look for
	 * @return an Array containing all matching objects
	 */
	public function getObjectsByType (type:Class) : Array {
		if (_destroyed) return null;
		var ids:Array = getIdsForType(type);
		var objects:Array = new Array();
		for each (var id:String in ids) {
			objects.push(getObject(id));
		}
		return objects;
	}
	
	/**
	 * Returns the type of the object of the specified id.
	 * Will recursively search in parent <code>ApplicationContext</code> instances
	 * if no matching configuration is found in this instance.
	 * 
	 * @param id the id of the object
	 * @return the type of the object for the specified id or null if no such object exists
	 */
	public function getType (id:String) : Class {
		if (_destroyed) return null;
		var type:Class;
		if (_config.factoryConfig.containsObject(id)) {
			type = _config.factoryConfig.getType(id);
		} else if (_parent != null) {
			type = _parent.getType(id);
		}
		if (type == null) {
			_logger.warn("No object registered with id '" + id + "'");
		}
		return type;
	}
	
	/**
	 * Returns the object for the specified id.
	 * Will recursively search in parent <code>ApplicationContext</code> instances
	 * if no matching configuration is found in this instance.
	 * For singleton instances that have already been accessed in this context,
	 * the existing instance will be returned. Otherwise a new instance will
	 * be created and configured.
	 * 
	 * @param id the id of the object
	 * @return the object for the specified id or null if no such object exists
	 */
	public function getObject (id:String) : Object {
		if (_destroyed) return null;
		var obj:Object;
 		if (_config.factoryConfig.containsObject(id)) {
 			if (_underConstruction.containsKey(id)) {
 				throw new ConfigurationError("Circular reference: Object with id '" 
 					+ id + "' is already under construction");
 			}
 			_underConstruction.put(id, true);
 			try {
				obj = _config.factoryConfig.getObject(id);
 			} catch (e:Error) {
 				// TODO - 1.1.0 - use nested errors
 				var msg:String = "Error constructing object with id '" + id + "'";
 				_logger.error(msg, e);
 				throw new ConfigurationError(msg + ": " + e.message);
 			} finally {
				_underConstruction.remove(id); // TODO - 1.1.0 - test and maybe allow bidirectional associations
 			}
		} else if (_parent != null) {
			obj = _parent.getObject(id);
		}
		if (obj == null) {
			_logger.warn("No object registered with id '" + id + "'");
		}
		return obj;
	}
	
	/**
	 * @private
	 */
	context_internal static function setLocaleManager (lm:LocaleManagerSpi) : void {
		if (lm != null && _localeManager != null) {
			throw new ConfigurationError("LocaleManager already created");
		} else if (lm != null && !(lm is LocaleManagerSpi)) {
			throw new ConfigurationError("Interface LocaleManagerSpi must be implemented");
		}
		_localeManager = lm;
	}
	
	/**
	 * The global <code>LocaleManager</code> instance.
	 */
	public static function get localeManager () : LocaleManager {
		return _localeManager;
	}
	
	/**
	 * @private
	 */
	context_internal function setMessageSource (ms:MessageSourceSpi) : void {
		if (!(ms is MessageSourceSpi)) {
			throw new Error("MessageSource must implement MessageSourceSpi interface");
		}
		_messageSource = MessageSourceSpi(ms);
	}
	
	/**
	 * The <code>MessageSource</code> instance associated with this <code>ApplicationContext</code>.
	 */
	public function get messageSource () : MessageSource {
		if (_messageSource == null) {
			_messageSource = new DefaultMessageSource();
		}
		return _messageSource;
	}
	
	/**
	 * Returns a localized message for the specified key.
	 * If no such message is available in the specified bundle, the key surrounded by double
	 * question marks will be returned (for example: <code>??myMessageKey??</code>).
	 * This way missing keys in the UI can be easily identified.
	 * If the optional bundle parameter is omitted the message will be taken from 
	 * the default bundle.
	 * 
	 * @param messageKey the key of the message
	 * @param bundle the name of the bundle to examine
	 * @param params optional parameters for parameterized messages
	 * @return the localized message for the specified key with all parameters applied
	 */
	public function getMessage (messageKey:String, bundle:String = null, params:Array = null) : String {
		var msg:String = _messageSource.getMessage(messageKey, bundle, params);
		if (msg == null && _parent != null) {
			msg = _parent.getMessage(messageKey, bundle, params);
		}
		if (msg == null) {
			var bundleLog:String = (bundle == null) ? "" : " in bundle '" + bundle + "'";
			_logger.warn("No message found for key '" + messageKey + "'" + bundleLog);
			return "??" + messageKey + "??";
		}
		return msg;
	}
	
	/**
	 * Adds a <code>Command</code> to this <code>ApplicationContext</code> that should be invoked
	 * after the <code>ApplicationContext</code> is fully parsed but before any object gets
	 * instantiated. This method offers a hook for custom tag implementations that need
	 * additional actions to be processed after the context is fully parsed.
	 * 
	 * @param com a Command that should be executed when this ApplicationContext gets destroyed
	 */
	public function addInitCommand (com:Command) : void {
		_initCommands.addCommand(com);
	}

	/**
	 * Adds a <code>Command</code> to this <code>ApplicationContext</code> that should be invoked
	 * when the <code>ApplicationContext</code> gets destroyed. Will be used internally,
	 * but can also be used by application code.
	 * 
	 * @param com a Command that should be executed when this ApplicationContext gets destroyed
	 */
	public function addDestroyCommand (com:Command) : void {
		_destroyCommands.addCommand(com);
	}
	
	/**
	 * Destroys this <code>ApplicationContext</code> instance.
	 * This involves invoking all methods that are configured with the 
	 * <code>&lt;destroy-method&gt;</code> tag and unbinding all message bindings.
	 * If this <code>ApplicationContext</code> has children they will all be destroyed
	 * recursively. Any parents of this <code>ApplicationContext</code> are not affected by
	 * this method.
	 */
	public function destroy () : void {
		if (_destroyed) {
			return;
		}
		// destroy children first
		for each (var context:ApplicationContext in _contextByName.values) {
			if (context.parent == this) {
				context.destroy();
			}
		}
		_destroyed = true;
		_contextByName.remove(_name);
		if (_root == this) {
			_root = null;
		}
		ApplicationContextParser.removeFromCache(this);
		_destroyCommands.execute();
		_destroyCommands = null;
		
		if (_messageSource != null) {
			_messageSource.destroy();
			_messageSource = null;
		}
		_config = null;
	}
		
}

}