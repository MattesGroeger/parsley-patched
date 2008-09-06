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
 
package org.spicefactory.parsley.context.tree.core {
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.converter.BooleanConverter;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.reflect.types.Any;
import org.spicefactory.lib.util.Command;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.converter.AutowireConverter;
import org.spicefactory.parsley.context.factory.FactoryMetadata;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractAttributeContainer;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.tree.core.enum.AutowireMode;
import org.spicefactory.parsley.context.tree.namespaces.template.nested.ApplyProcessorChildrenConfig;
import org.spicefactory.parsley.context.tree.values.ArrayConfig;
import org.spicefactory.parsley.context.util.BooleanValue;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * The default <code>ObjectFactoryConfig</code> implementation.
 * 
 * 
 */
public class DefaultObjectFactoryConfig	
		extends AbstractAttributeContainer implements ApplicationContextAware, ObjectFactoryConfig {
	
	
	private var _context:ApplicationContext;
	
	private var _id:String;
	private var _type:ClassInfo;
	private var _singleton:BooleanValue;
	private var _lazy:BooleanValue;
	private var _autowire:AutowireMode;
	
	private var _constructorArgsConfig:ArrayConfig;
	private var _factoryMethodConfig:FactoryMethodConfig;
	
	private var _processorConfigs:Array;
	private var _explicitProperties:Dictionary = new Dictionary();
	
	private var _destroyMethodConfigs:Array;
	
	private static var _logger:Logger;
	
	
	/**
	 * @inheritDoc
	 */
	public function parseRootObject (node : XML, context : ApplicationContext) : FactoryMetadata {
		getRootElementProcessor(context).parse(node, this, context);
		return new FactoryMetadata(id, singleton, lazy);
	}
	/**
	 * @inheritDoc
	 */
	public function parseNestedObject (node : XML, context : ApplicationContext) : void {
		getNestedElementProcessor(context).parse(node, this, context);
	}
	
	
	
	private static var _topLevelElementProcessor:ElementProcessor;
	private static var _nestedElementProcessor:ElementProcessor;
	
	private function getRootElementProcessor (context:ApplicationContext) : ElementProcessor {
		if (_topLevelElementProcessor == null) {
			_topLevelElementProcessor = createElementProcessor(context, false);
		}
		return _topLevelElementProcessor;
	}
	
	private function getNestedElementProcessor (context:ApplicationContext) : ElementProcessor {
		if (_nestedElementProcessor == null) {
			_nestedElementProcessor = createElementProcessor(context, true);
		}
		return _nestedElementProcessor;
	}
	
	private function createElementProcessor (context:ApplicationContext, isInline:Boolean) : DefaultElementProcessor {
		var ep:DefaultElementProcessor = new DefaultElementProcessor();
		if (!isInline) {
			ep.addAttribute("id", StringConverter.INSTANCE, true);
			ep.addAttribute("singleton", BooleanConverter.INSTANCE, false, true);
			ep.addAttribute("lazy", BooleanConverter.INSTANCE, false, true);
		}
		ep.addChildNode("constructor-args", ArrayConfig, [], 0, 1);
		ep.addChildNode("factory-method", InstanceFactoryMethodConfig, [], 0, 1);
		ep.addChildNode("static-factory-method", StaticFactoryMethodConfig, [], 0, 1);
		
		ep.addChildNode("property", PropertyConfig, [], 0);
		ep.addChildNode("init-method", MethodInvocationConfig, [], 0);
		ep.addChildNode("listener", ListenerConfig, [], 0);
		ep.addChildNode("destroy-method", MethodInvocationConfig, [], 0);
		
		ep.addChildNode("apply-children", ApplyProcessorChildrenConfig, [], 0);
		
		ep.permitCustomNamespaces(ObjectProcessorConfig);
		
		var defType:ClassInfo = ClassInfo.forClass(Object);
		ep.addAttribute("type", new ClassInfoConverter(null, context.applicationDomain), false, defType);
		ep.addAttribute("autowire", AutowireConverter.INSTANCE, false);
		
		return ep;
	}
	
	
	/**
	 * Creates a new instance.
	 */
	public function DefaultObjectFactoryConfig () {
		if (_logger == null) {
			_logger = LogContext.getLogger("org.spicefactory.parsley.context.tree.core.ObjectConfig");
		}
		_constructorArgsConfig = new ArrayConfig(); // default with no arguments
		_processorConfigs = new Array();
		_destroyMethodConfigs = new Array();
	}
	
	
	public function set applicationContext (context:ApplicationContext) : void {
		_context = context;
	}
	/**
	 * @inheritDoc
	 */	
	public function get applicationContext () : ApplicationContext {
		return _context;
	}
	
	public function set id (id:String) : void {
		_id = id;
	}
	
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#id
	 */
	public function get id () : String {
		if (_id != null) {
			return _id;
		} else {
			return getAttributeValue("id");
		}
	}
	
	public function set type (value:ClassInfo) : void {
		_type = value;
	}
	/**
	 * @inheritDoc
	 */	
	public function get type () : ClassInfo {
		if (_type != null) {
			return _type;
		} else {
			return getAttributeValue("type");
		}
	}
	
	public function set singleton (value:Boolean) : void {
		_singleton = new BooleanValue(value);
	}

	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#singleton
	 */	
	public function get singleton () : Boolean {
		if (_singleton != null) {
			return _singleton.value;
		} else {
			return getAttributeValue("singleton");
		}
	}
	
	public function set lazy (value:Boolean) : void {
		_lazy = new BooleanValue(value);
	}
	
	/**
	 * @copy org.spicefactory.parsley.context.tree.core.RootObjectFactoryConfig#lazy
	 */
	public function get lazy () : Boolean {
		if (_lazy != null) {
			return _lazy.value;
		} else {
			return getAttributeValue("lazy");
		}
	}
	
	public function set autowire (value:AutowireMode) : void {
		_autowire = value;
	}
	
	/**
	 * The autowire mode for this object factory. Properties can be autowired by type or
	 * by name or autowiring may be turned off.
	 */ 
	public function get autowire () : AutowireMode {
		if (_autowire != null) {
			return _autowire;
		} else {
			var autowire:AutowireMode = getAttributeValue("autowire");
			return (autowire == null) ? _context.config.factoryConfig.autowire : autowire;
		}
	}
	
	
	/**
	 * The configuration for the constructor arguments to use when instantiating
	 * the object.
	 */
	public function set constructorArgsConfig (config:ArrayConfig) : void {
		_constructorArgsConfig = config;
	}
	
	/**
	 * The configuration for the factory method to use for instantiating the object.
	 */
	public function set factoryMethodConfig (config:FactoryMethodConfig) : void {
		_factoryMethodConfig = config;
	}
	
	/**
	 * The configuration for the static factory method to use for instantiating the object.
	 */
	public function set staticFactoryMethodConfig (config:FactoryMethodConfig) : void {
		// use the same property as for setFactoryMethod
		// since only one can be specified and both are of the same type
		// TODO - 1.0.1 - maybe check if it was already set and throw an error
		// TODO - 1.1.0 - check if return type of method corresponds to type property of this instance
		_factoryMethodConfig = config;
	}
	
	/**
	 * Adds the configuration for a single property value.
	 * 
	 * @param config the configuration for a single property value.
	 */
	public function addPropertyConfig (config:PropertyConfig) : void {
		_explicitProperties[config.name] = true;
		_processorConfigs.push(config);
	}
	
	/**
	 * Adds the configuration for a single method invocation.
	 * 
	 * @param config the configuration for a single method invocation.
	 */
	public function addInitMethodConfig (config:MethodInvocationConfig) : void {
		_processorConfigs.push(config);
	}
	
	/**
	 * Adds the configuration for a method that gets invoked on the object created
	 * by this factory when the <code>ApplicationContext</code> gets destroyed.
	 * 
	 * @param config the configuration for a method to invoke when the object gets destroyed
	 */
	public function addDestroyMethodConfig (config:MethodInvocationConfig) : void {
		_destroyMethodConfigs.push(config);
	}	
	
	/**
	 * Adds the configuration for a single listener.
	 * 
	 * @param config the configuration for a single listener.
	 */
	public function addListenerConfig (config:ListenerConfig) : void {
		_processorConfigs.push(config);
	}
	
	/**
	 * Adds the configuration for children of a template-based custom tag.
	 * 
	 * @param config the configuration for children of a template-based custom tag.
	 */
	public function addApplyChildrenConfig (config:ApplyProcessorChildrenConfig) : void {
		_processorConfigs.push(config);
	}
	
	/**
	 * Adds the configuration for a custom tag.
	 * 
	 * @param config the configuration for a custom tag.
	 */
	public function addCustomConfig (config:ObjectProcessorConfig) : void {
		_processorConfigs.push(config);
	}	
	
	
	/**
	 * @inheritDoc
	 */
	public function createObject () : Object {

		// create object
		var obj:Object = instantiate();
		
		// apply configuration
		var destroyCommands:CommandChain = new CommandChain();
		configureObject(obj, destroyCommands);

		// handle destroy method
		handleDestroyMethods(obj, destroyCommands);
		
		// pass CommandChain
		if (!destroyCommands.isEmpty()) {
			_context.addDestroyCommand(destroyCommands);
		}
			
		return obj;
	}
	
	private function instantiate () : Object {
		var obj:Object;
		if (_factoryMethodConfig != null) {
			obj = _factoryMethodConfig.createInstance();
			if (obj == null) {
				throw new ConfigurationError("Specified factory method did not return an object");
			}
		} else {
			obj = type.newInstance(_constructorArgsConfig.value);
		}
		return obj;
	}	
	
	private function configureObject (obj:Object, destroyCommands:CommandChain) : void {
		var ci:ClassInfo = (type == null) ? ClassInfo.forInstance(obj, _context.applicationDomain) : type;
		for (var i:Number = 0; i < _processorConfigs.length; i++) {
			var processor:ObjectProcessorConfig = ObjectProcessorConfig(_processorConfigs[i]);
			try {
				processor.process(obj, ci, destroyCommands);
			} catch (e:Error) {
				throw new ConfigurationError("Error applying configuration to " + this + ": " + e.message);
			}
		}
		if (obj is ApplicationContextAware) {
			ApplicationContextAware(obj).applicationContext = _context;
		}
		if (autowire != AutowireMode.OFF) {
			var props:Array = ci.getProperties();
			
			if (autowire == AutowireMode.BY_NAME) {
				for each (var prop1:Property in props) {
					if (prop1.writable && !_explicitProperties[prop1.name] && _context.containsObject(prop1.name)) {
						prop1.setValue(obj, _context.getObject(prop1.name));
					}
				}
			} else {
				for each (var prop2:Property in props) {
					if (!prop2.writable || _explicitProperties[prop2.name]) continue;
					var propType:Class = prop2.type;
					if (propType == Any 
						|| propType == Object
						|| propType == Boolean
						|| propType == String
						|| propType == uint
						|| propType == int
						|| propType == Number) continue;
					var candidates:Array = _context.getIdsForType(propType);
					if (candidates.length > 0) {
						if (candidates.length > 1) {
							var msg:String = "Autowire: More than one object of type " + getQualifiedClassName(type) 
								+ " registered, ids = " + candidates.join(",");
							_logger.error(msg);
							throw new ConfigurationError(msg);
						}
						prop2.setValue(obj, _context.getObject(candidates[0]));
					} else {
						// TODO - 1.0.1 - handle missing dependency - warning or error?
						//var msg:String = "Autowire: No objects of type " + getQualifiedClassName(type) 
								//+ " registered for autowired property " + prop2.name;
							//_logger.warn(msg);
					}
				}	
			}
		}
	}	
		
	
	private function handleDestroyMethods (obj:Object, chain:CommandChain) : void {
		for each (var config:MethodInvocationConfig in _destroyMethodConfigs) {
			var com:Command = new Command(config.invoke, [obj]);
			chain.addCommand(com);
		}
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		var idStr:String = (id != null) ? " with id'" + id + "'" : "";
		return "Object" + idStr + ", class = " + type.name;
	}
	
	
	
}

}