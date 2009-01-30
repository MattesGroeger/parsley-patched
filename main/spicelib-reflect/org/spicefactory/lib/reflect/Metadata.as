/*
 * Copyright 2008 the original author or authors.
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

package org.spicefactory.lib.reflect {
import org.spicefactory.lib.reflect.metadata.Required;

import flash.system.ApplicationDomain;

import org.spicefactory.lib.reflect.metadata.EventInfo;

/**
 * Represents a single metadata tag associated with a class, property or method declaration.
 * 
 * @author Jens Halm
 */
public class Metadata {
	
	
	private static var metadataClasses:Object = new Object();
	private static var initialized:Boolean = false;
	
	private var _name:String;
	private var _arguments:Object;
	private var registration:MetadataClassRegistration;
	
	
	/**
	 * @private
	 */
	function Metadata (name:String, args:Object, reg:MetadataClassRegistration = null) {
		_name = name;
		_arguments = args;
		registration = reg;
	}

	
	/**
	 * @private
	 */
	internal static function fromXml (xml:XML, type:String) : Metadata {
		if (!initialized) initialize();
		var name:String = xml.@name;
		var args:Object = new Object();
		for each (var argTag:XML in xml.arg) {
			args[argTag.@key] = argTag.@value;
		} 
		return new Metadata(name, args, MetadataClassRegistration(metadataClasses[name + " " + type]));
	}
	
	
	/**
	 * Registers a custom Class for representing metadata tags.
	 * If no custom Class is registered for a particular tag an instance of this generic <code>Metadata</code>
	 * class will be used to represent the tag and its arguments. For type-safe access to such
	 * tags a custom Class can be registered. In this case the arguments of the metadata tag
	 * will be mapped to the corresponding properties with the same name. Type conversion occurs 
	 * automatically if necessary. If the builtin basic Converters are not sufficient for a particular
	 * type you can register custom <code>Converter</code> instances with the <code>Converters</code>
	 * class. Arguments on the metadata tag without a matching property will be silently ignored. 
	 * 
	 * <p>The specified metadata class should be annotated itself with a <code>[Metadata]</code> tag.
	 * See the documentation for the <code>MappedMetadata</code> class for details.</p>
	 * 
	 * @param metadataClass the custom Class to use for representing that tag
	 * @param appDomain the ApplicationDomain to use for loading classes when reflecting on the specified 
	 * Metadata class
	 */
	public static function registerMetadataClass (metadataClass:Class, 
			appDomain:ApplicationDomain = null) : void {
		if (!initialized) initialize();
		//ClassInfo.clearCache();
		var reg:MetadataClassRegistration = 
				new MetadataClassRegistration(ClassInfo.forClass(metadataClass, appDomain));
		for each (var key:String in reg.registrationKeys) {
			metadataClasses[key] = reg;
		} 
	}
	
	private static function initialize () : void {
		initialized = true;
		for each (var reg:MetadataClassRegistration in MetadataClassRegistration.createInternalRegistrations()) {
			for each (var key:String in reg.registrationKeys) {
				metadataClasses[key] = reg;
			} 
		}
		registerMetadataClass(Required);
		registerMetadataClass(EventInfo);
	}
	
	/**
	 * The name of the metadata tag.
	 */
	public function get name () : String {
		return _name;
	}
	
	/**
	 * Returns the argument for the specified key as a String or null if no such argument exists.
	 * 
	 * @return the argument for the specified key as a String or null if no such argument exists
	 */
	public function getArgument (key:String) : String {
		return _arguments[key];
	} 
	

	/**
	 * Returns the default argument as a String or null if no such argument exists.
	 * The default argument is the value that was specified without an excplicit key (e.g.
	 * <code>[Meta("someValue")]</code> compared to <code>[Meta(key="someValue")]</code>).
	 * 
	 * @return the default argument as a String or null if no such argument exists
	 */
	public function getDefaultArgument () : String {
		return _arguments[""];
	} 
	
	
	/**
	 * @private
	 */
	internal function getExternalValue () : Object {
		if (registration == null) {
			return this;
		}
		else {
			// Create a new instance on each access so that modifications of property values
			// have no effect.
			var instance:Object = registration.metadataType.newInstance([]);
			for (var key:String in _arguments) {
				var propName:String = (key == "") ? registration.defaultProperty : key;
				var p:Property = registration.metadataType.getProperty(propName);
				if (p == null || !p.writable) {
					trace("Unable to set property with name "
							+ propName + " on metadata class " + registration.metadataType.name
							+ ": Property does not exist or is not writable");
					continue;
				}
				try {
					var value:* = (p.type.isType(Array)) ? _arguments[key].split(",") : _arguments[key];
					p.setValue(instance, value);
				}
				catch (e:Error) {
					trace("Unable to set property with name "
							+ propName + " on metadata class " + registration.metadataType.name, e);
				}
			} 
			return instance;
		}
	}
	
	/**
	 * @private
	 */
	internal function getKey () : Object {
		if (registration == null) {
			return _name;
		}
		else {
			return registration.metadataType.getClass();
		}
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return "[Metadata name=" + name + "]";
	}
	
	
}
}

import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.metadata.MappedMetadata;
import org.spicefactory.lib.reflect.metadata.DefaultProperty;
import org.spicefactory.lib.reflect.metadata.Types;

class MetadataClassRegistration {
	
	
	public var name:String;
	public var metadataType:ClassInfo;
	public var defaultProperty:String;
	public var annotatedTypes:Array;
	
	
	public static function createInternalRegistrations () : Array {
		/* Internal tags like [Metadata] cannot be created through Reflection
		   as this would lead to a chicken-and-egg problem. */
	    var internalRegs:Array = new Array();
	    internalRegs.push(createRegistration("Metadata", 
	   			ClassInfo.forClass(MappedMetadata), [Types.CLASS]));
	    internalRegs.push(createRegistration("DefaultProperty", 
	    		ClassInfo.forClass(DefaultProperty), [Types.PROPERTY]));
	    return internalRegs;
	}
	
	private static function createRegistration (name:String, metadataType:ClassInfo, annotatedTypes:Array)
			: MetadataClassRegistration {
		var reg:MetadataClassRegistration = new MetadataClassRegistration();
		reg.name = name;
		reg.metadataType = metadataType;
		reg.annotatedTypes = annotatedTypes;
		return reg;
	}

	
	function MetadataClassRegistration (type:ClassInfo = null) {
		if (type != null) {
			var metadata:Array = type.getMetadata(MappedMetadata);
			if (metadata.length != 1) {
				throw new IllegalArgumentError("Expected exactly one [Metadata] tag on Class " + type.name);
			}
			var mappedMetadata:MappedMetadata = MappedMetadata(metadata[0]);
			this.name = (mappedMetadata.name == null) ? type.simpleName : mappedMetadata.name;
			this.metadataType = type;
			this.annotatedTypes = (mappedMetadata.types == null || mappedMetadata.types.length == 0)
					? [Types.CLASS, Types.CONSTRUCTOR, Types.PROPERTY, Types.METHOD] : mappedMetadata.types;
			var defaultProperties:Array = new Array();
			for each (var p:Property in type.getProperties()) {
				metadata = p.getMetadata(DefaultProperty);
				if (metadata.length > 1) {
					throw new IllegalArgumentError("Expected no more than one [DefaultProperty] tag on " + p);
				}
				else if (metadata.length == 1) {
					defaultProperties.push(p.name);
				}
			}
			if (defaultProperties.length > 1) {
				throw new IllegalArgumentError("Expected no more than one property annotated " +
						"with [DefaultProperty] on Class " + metadataType.name);
			}
			else if (defaultProperties.length == 1) {
				this.defaultProperty = defaultProperties[0];
			}
		}
	}
	
	public function get registrationKeys () : Array {
		var keys:Array = new Array();
		for each (var type:String in annotatedTypes) {
			keys.push(name + " " + type);
		}
		return keys;
	}
	
	
}

