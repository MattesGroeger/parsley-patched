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
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.EnumerationConverter;
import org.spicefactory.lib.util.collection.MapEntry;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.core.enum.AutowireMode;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.context.ApplicationContext;

/**
 * Represents the <code>&lt;factory&gt;</code> tag, the root tag for all object configurations.
 * 
 * @author Jens Halm
 */
public class FactoryConfig 
		extends AbstractElementConfig {
	
	
	private var _objectFactoryConfigs:SimpleMap;
	private var _autowire:AutowireMode;
	
	private var _nodes:Array = new Array();
	private var _context:ApplicationContext;
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			ep.addChildNode("object", DelegatingRootObjectFactoryConfig, [DefaultObjectFactoryConfig], 0);
			ep.permitCustomNamespaces(RootObjectFactoryConfig);
			ep.addAttribute("autowire", new EnumerationConverter(ClassInfo.forClass(AutowireMode)), false, AutowireMode.OFF);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * Creates a new instance.
	 */
	function FactoryConfig () {
		_objectFactoryConfigs = new SimpleMap();
	}
	
	public function set autowire (value:AutowireMode) : void {
		_autowire = value;
	}
	
	/**
	 * The default autowire mode for this factory. Can be overridden for 
	 * each individual object configuration.
	 */
	public function get autowire () : AutowireMode {
		if (_autowire != null) {
			return _autowire;
		} else {
			return getAttributeValue("autowire");
		}
	}
	
	/**
	 * Adds an object configuration to this factory.
	 * 
	 * @param config the object configuration to add to this factory
	 */
	public function addChildConfig (config:RootObjectFactoryConfig) : void {
		if (containsObject(config.id)) {
			throw new ConfigurationError("Duplicate object id: " + config.id);
		}
		
		_objectFactoryConfigs.put(config.id, config);
	}
	
	/**
	 * The number of object configurations in this factory.
	 */
	public function get objectCount () : uint {
		return _objectFactoryConfigs.getSize();
	}
	
	/**
	 * An Array with all ids of the object configuration contained in this factory.
	 */
	public function get objectIds () : Array {
		return _objectFactoryConfigs.keys;
	}
	
	/**
	 * Indicates whether an object configuration for the specified id exists in this factory.
	 * 
	 * @param id the id to look for
	 * @return true if an object configuration for the specified id exists in this factory
	 */
	public function containsObject (id:String) : Boolean {
		return _objectFactoryConfigs.containsKey(id);
	}
	
	/**
	 * Returns a fully configured instance for the specified id.
	 * 
	 * @param id the id of the object to return
	 * @return the fully configured instance for the specified id or null if no such object exists
	 */
	public function getObject (id:String) : Object {
		if (!containsObject(id)) {
			return null;
		}
		var config:RootObjectFactoryConfig = RootObjectFactoryConfig(_objectFactoryConfigs.get(id));
		return config.createObject();
	}
	
	/**
	 * Returns the class of the object for the specified id.
	 * 
	 * @param id the id of the object to return the class for
	 * @return the class of the object for the specified id
	 */
	public function getType (id:String) : Class {
		if (!containsObject(id)) {
			return null;
		}
		var config:RootObjectFactoryConfig = RootObjectFactoryConfig(_objectFactoryConfigs.get(id));
		return config.type.getClass();
	}
	
	/**
	 * Returns all ids for objects that are instances of (or subtypes of) the specified class.
	 * 
	 * @param type the class to look for
	 * @return an Array with all ids for objects that are instances of (or subtypes of) the specified class
	 */
	public function getIdsForType (type:Class) : Array {
		var ids:Array = new Array();
		for each (var entry:MapEntry in _objectFactoryConfigs.entries) {
			var config:RootObjectFactoryConfig = entry.value as RootObjectFactoryConfig;
			if (config.type.isType(type)) {
				ids.push(entry.key);
			}
		}
		// TODO - 1.0.1 - cache Array
		return ids;
	}
	
	/**
	 * Merges the content of another factory configuration with this one.
	 * Does not allow duplicate ids.
	 * 
	 * @param fc the factory configuration to merge with this one
	 */
	public function merge (fc:FactoryConfig) : void {
		// TODO - 1.1.0 - maybe use context_internal namespace for merge and process functions
		/*
		var keys:Array = fc._objectFactoryConfigs.keys;
		for (var i:Number = 0; i < keys.length; i++) {
			var config:RootObjectFactoryConfig = RootObjectFactoryConfig(fc._objectFactoryConfigs.get(keys[i]));
			addChildConfig(config);
		}
		*/
		_nodes = _nodes.concat(fc._nodes);
	}

	/**
	 * @inheritDoc
	 */
	public override function parse (node : XML, context : ApplicationContext) : void {
		_nodes.push(node);
		_context = context;
		//super.parse(node, context);
	}

	/**
	 * Processes the XML. This object does not process the XML in the <code>parse</code> method
	 * like other configuration objects since the parser must first collect the nodes from (possibly)
	 * multiple configuration files.
	 */
	public function processXml () : void {
		for each (var node:XML in _nodes) {
			super.parse(node, _context);
		}
	}
	
	/**
	 * Processes the object configurations of this factory.
	 * This method will be executed once after all configuration artifacts have been parsed.
	 * It will instantiate all objects which have the <code>singleton</code> property set to
	 * <code>true</code> and the <code>lazy</code> property set to <code>false</code>.
	 */
	public function processObjects () : void {
		for each (var config:RootObjectFactoryConfig in _objectFactoryConfigs.values) {
			if (config.singleton && !config.lazy) {
				config.createObject();
			}
		}
	}
	
	
}

}