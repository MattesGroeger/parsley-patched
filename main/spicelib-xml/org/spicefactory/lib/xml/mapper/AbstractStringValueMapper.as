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

package org.spicefactory.lib.xml.mapper {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.reflect.metadata.Required;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.lib.xml.impl.ValueConfig;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class AbstractStringValueMapper {
	
	
	private var _targetType:ClassInfo;
	private var _namespaceUri:String;
	
	
	private var xmlConfigs:Dictionary = new Dictionary();
	private var propertyConfigs:Dictionary = new Dictionary();
	private var valueConfigs:Array = new Array();
	
	
	function AbstractStringValueMapper (targetType:ClassInfo, namespaceUri:String = null) {
		this._targetType = targetType;
		this._namespaceUri = namespaceUri;
	}

	
	protected function get targetType () : ClassInfo {
		return _targetType;
	}
	
	protected function getXmlConfig (xmlName:String) : ValueConfig {
		return xmlConfigs[new QName(_namespaceUri, xmlName).toString()];
	}
	
	protected function getPropertyConfig (propertyName:String) : ValueConfig {
		return propertyConfigs[propertyName];
	}
	
	protected function getAllConfigs () : Array {
		return valueConfigs.concat();
	}
	
	
	public function mapAllProperties () : void {
		for each (var property:Property in targetType.getProperties()) {
			if (property.writable) {
				addPropertyMapping(property);
			}
		}
	}
	
	public function mapProperty (propertyName:String, attributeName:String = null) : void {
		var property:Property = targetType.getProperty(propertyName);
		if (property == null || !property.writable) {
			throw new IllegalArgumentError(property.toString() + " does not exist or is not writable"); 
		}		
		addPropertyMapping(property);	
	}
	
	private function addPropertyMapping (property:Property, attributeName:String = null) : void {
		if (attributeName == null) attributeName = XmlProcessorContext.namingStrategy.toXmlName(property.name);
		var required:Boolean = property.getMetadata(Required).length != 0;
		var config:ValueConfig = new ValueConfig(new QName(_namespaceUri, attributeName), property, required);
		xmlConfigs[_namespaceUri + "::" + attributeName] = config;
		propertyConfigs[property.name] = config;
		valueConfigs.push(config);
	}
	
	
	public function ignoreProperty (propertyName:String) : void {
		var config:ValueConfig = propertyConfigs[propertyName];
		if (config != null) {
			delete xmlConfigs[config.xmlName];
			delete propertyConfigs[config.property.name];
			valueConfigs.splice(valueConfigs.indexOf(config, 1));
		}
	}
	
	
}
}
