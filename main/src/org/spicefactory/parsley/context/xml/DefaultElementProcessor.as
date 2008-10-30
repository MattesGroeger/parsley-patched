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
 
package org.spicefactory.parsley.context.xml {
import org.spicefactory.lib.expr.Expression;
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.tree.Attribute;
import org.spicefactory.parsley.context.tree.AttributeContainer;
import org.spicefactory.parsley.context.tree.namespaces.NamespaceChildConfig;

/**
 * The default <code>ElementProcessor</code> implementation.
 * This implementation has several rules for matching XML attribute names to 
 * property names of configuration objects and matching names of child nodes to
 * methods which will be invoked to pass the configuration objects populated by that child node.
 * 
 * <p>This is the mechanism that applies to the whole Parsley context parsing process.</p>
 * 
 * @author Jens Halm
 */
public class DefaultElementProcessor implements ElementProcessor {

	
	public static const PARSLEY_NAMESPACE_URI:String = "http://www.spicefactory.org/parsley/1.0";
	public static const SCHEMA_NAMESPACE_URI:String = "http://www.w3.org/2001/XMLSchema-instance";
	
	
	private var _attributeConfigs:Object;
	private var _textNode:AttributeConfig;
	private var _childConfigs:Object;
	private var _customNamespaceChildConfig:ChildConfig;
	
	private var _singleArrayMode:Boolean = false;
	private var _minChildCount:Number;
	private var _maxChildCount: Number;
	public var _ignoreAttributes : Boolean = false;

	
	/**
	 * Creates a new instance.
	 */
	function DefaultElementProcessor () {
		_singleArrayMode = false;
		_childConfigs = new Object();
		_attributeConfigs = new Object();
	}
	
	public function set ignoreAttributes (value:Boolean) : void {
		_ignoreAttributes = value;
	}
	
	/**
	 * Indicates whether attributes should be processed or ignored.
	 */
	public function get ignoreAttributes () : Boolean {
		return _ignoreAttributes;
	}
	
	/**
	 * Invoked when nodes from custom configuration namespaces are allowed as child nodes of
	 * the node processed by this instance.
	 * 
	 * @param CustomNamespaceChildConfig the configuration class responsible for processing child nodes
	 * from custom namespaces
	 */
	public function permitCustomNamespaces (CustomNamespaceChildConfig:Class) : void {
		_customNamespaceChildConfig = new NamespaceChildConfig(CustomNamespaceChildConfig);
	}
	
	/**
	 * Invoked when all child nodes should be merged into a single Array value and
	 * should not be applied to the parent node individually.
	 * 
	 * @param minChildCount the minimum number of required child nodes
	 * @param maxChildCount the maximum number of allowed child nodes
	 */
	public function setSingleArrayMode (minChildCount:uint, maxChildCount:uint = 0) : void {
		// all children will be merged into a single array regardless of their type
		_singleArrayMode = true;
		_minChildCount = minChildCount;
		_maxChildCount = maxChildCount;
	}
	
	/**
	 * Adds a child node configuration to this processor.
	 * 
	 * @param name the local name of the child node
	 * @param ChildClass the class of the configuration object processing the child node
	 * @param constructorArgs the arguments to pass to the constructor of the class processing the child
	 * @param minOccurs the minimum number of required occurrences of that child node
	 * @param maxOccurs the maximum number of allowed occurrences of that child node
	 */
	public function addChildNode (name:String, ChildClass:Class, 
			constructorArgs:Array, minOccurs:Number, maxOccurs:Number = 0) : void {
		_childConfigs[name] = new DefaultChildConfig(name, ChildClass, constructorArgs, minOccurs, maxOccurs);
	}
	
	/**
	 * Adds an attribute configuration to this processor.
	 * 
	 * @param name the local name of the attribute
	 * @param conv the Converter instance to use for converting the attribute value
	 * @param required whether this attribute is required
	 * @param defaultValue an optional default value for this attribute
	 */
	public function addAttribute (name:String, conv:Converter, required:Boolean, defaultValue:* = undefined) : AttributeConfig {
		var config:AttributeConfig = new AttributeConfig(name, conv, required, defaultValue);
		_attributeConfigs[name] = config;
		return config;
	}
	
	/**
	 * Adds a text node configuration to this processor.
	 * 
	 * @param name the name of the property that the content of the text node should be applied to
	 * @param conv the Converter instance to use for converting the value of the text node
	 * @param required whether the text node is required
	 * @param defaultValue an optional default value for the text node
	 */
	public function addTextNode (name:String, conv:Converter, required:Boolean, defaultValue:* = undefined) : AttributeConfig {
		var config:AttributeConfig = new AttributeConfig(name, conv, required, defaultValue);
		//_attributeConfigs[name] = config; ????
		_textNode = config;
		return config;
	}
	
	/**
	 * @inheritDoc
	 */
	public function parse (node:XML, config:AttributeContainer, context:ApplicationContext) : void {
		
		if (config is ApplicationContextAware) {
			ApplicationContextAware(config).applicationContext = context;
		}
		if (!_ignoreAttributes) {
			parseAttributes(node, config, context);
		}
		
		if (_textNode != null) {
			parseTextNode(node, config, context);
		} else if (_singleArrayMode) {
			parseChildArray(node, config, context);
		} else {
			parseChildMap(node, config, context);
		}
		
	}


	private function parseAttributes (node:XML, container:AttributeContainer, context:ApplicationContext) : void {
		// check for unexpected attributes
		var attList:XMLList = node.attributes();
		for each (var attr:XML in attList) {
			var qName:QName = attr.name() as QName;
			if (qName.uri == SCHEMA_NAMESPACE_URI) continue; // ignore
			var name:String = qName.localName;
			if (_attributeConfigs[name] == null) {
				throw new ConfigurationError("Unexpected attribute '" + name + "' in node: " + node.nodeName);
			}
		}
		// check all permitted attributes
		for each (var attrConfig:AttributeConfig in _attributeConfigs) {
			attList = node.attribute(attrConfig.name);
			var value:String = (attList.length() > 0) ? attList[0] : null;
			applyAttribute(attrConfig, container, value, "attribute '" + attrConfig.name + "'", 
				node.name() as QName, context);
		}
	}
	
	private function parseTextNode (node:XML, container:AttributeContainer, context:ApplicationContext) : void {
		var text:XMLList = node.text();
		if (text.length() > 1) {
			throw new ConfigurationError("Expected exactly one text node in node: " + node.name());
		}
		var value:String = (text.length() > 0) ? text[0] : null;
		applyAttribute(_textNode, container, value, "child text node", node.name() as QName, context);
	}
	
	private function applyAttribute (attr:AttributeConfig, config:AttributeContainer, value:String,
			info:String, nodeName:QName, context:ApplicationContext) : void {
		if (value == null) {
			if (attr.required) { 
				throw new ConfigurationError("Missing required " + info + " in node: " + nodeName);
			} else if (attr.defaultValue == undefined) {
				return;
			}
		}
		var expr:Expression = (value == null) ? null : context.expressionContext.createExpression(value);
		config.setAttribute(convertXmlToCamelCase(attr.name, false), new Attribute(expr, attr));		
	}
			

	private function checkIfValidChild (node:XML, parent:XML) : Boolean {
		if (node.nodeKind() == "text") {
			throw new ConfigurationError("No text nodes allowed in node: " + node.name());
		}
		if (node.nodeKind() != "element") {
			return false;
		}
		var name:QName = node.name() as QName;
		if (name.uri == PARSLEY_NAMESPACE_URI) {
			if (_childConfigs[name.localName] == undefined) {
				throw new ConfigurationError("Unexpected child node '" + name.localName + "' in node '" + parent.localName() + "'");
			}
		} else if (_customNamespaceChildConfig == null) {
			throw new ConfigurationError("Unexpected child node '" + name.localName + "' in node '" + parent.localName() + "'");
		}
		return true;
	}
	
	private function getChildConfig (node:XML) : ChildConfig {
		var name:QName = node.name() as QName;
		if (name.uri.length == 0) {
			throw new ConfigurationError("Encountered node without namespace: " + node.localName());
		}
		if (name.uri == PARSLEY_NAMESPACE_URI) {
			return ChildConfig(_childConfigs[name.localName]);
		} else {
			return _customNamespaceChildConfig;
		}		
	}
	
	private function parseChildArray (node:XML, container:AttributeContainer, context:ApplicationContext) : void {
		// filter child nodes
		var children:XMLList = node.children();
		for each (var child:XML in children) {
			checkIfValidChild(child, node);
		}
		// check if total number of children is valid
		if (children.length() < _minChildCount || (_maxChildCount != 0 && children.length > _maxChildCount)) {
			throw new ConfigurationError("Illegal number of child nodes in node: <" + node.localName() + 
				">: expected minimum " + _minChildCount 
				+ ((_maxChildCount != 0) ? " - expected maxiumum " + _maxChildCount : "")
				+ " - actual count: " + children.length());
		}	
		// parse children and populate target object
		parseAndApplyChildren(children, container, context, true);		
	}
	
	private function parseChildMap (node:XML, container:AttributeContainer, context:ApplicationContext) : void {
		// sort child nodes
		var childMap:Object = new Object;
		for (var childName:String in _childConfigs) {
			childMap[childName] = new Array();
		}
		var children:XMLList = node.children();
		for each (var child:XML in children) {
			if (checkIfValidChild(child, node)) {
				var name:QName = child.name() as QName;
				if (name.uri == PARSLEY_NAMESPACE_URI) {
					childMap[name.localName].push(child);
				}
			}
		}
		// check if the number of child nodes for each permitted type is valid
		for each (var childConfig:ChildConfig in _childConfigs) {
			if (!childConfig.isValidCount(childMap[childConfig.name].length)) {
				throw new ConfigurationError("Illegal number of child nodes '" + childConfig.name + "' in node: '" + node.name() + "'");
			}
		}
		// parse children and populate target object
		parseAndApplyChildren(children, container, context, false);		
	}
	
	
	private function parseAndApplyChildren (
			children:XMLList, 
			config:AttributeContainer, 
			context:ApplicationContext, 
			asSingleArray:Boolean
			) : void {
		for each (var child:XML in children) {
			var childConfig:ChildConfig = getChildConfig(child);
			var childObj:ElementConfig = childConfig.createChild(context, child);
			childObj.parse(child, context);
			var methodName:String = null;
			var propertyName:String = null;
			if (asSingleArray) {
				if (_maxChildCount == 1) {
					propertyName = "childConfig";
				} else {
					methodName = "addChildConfig";
				}
				//methodName = (_maxChildCount == 1) ? "setChildConfig" : "addChildConfig";
			} else {
				if (childConfig.isSingleton()) {
					propertyName = convertXmlToCamelCase(child.localName() as String, false) + "Config";
				} else {
					var name:QName = child.name() as QName;
					if (name.uri == PARSLEY_NAMESPACE_URI) {
						methodName = "add" + convertXmlToCamelCase(child.localName() as String, true) + "Config";
					} else {
						methodName = "addCustomConfig";
					}
				}
				//methodName = (childConfig.isSingleton()) ? "set" : "add";
				//methodName += convertXmlToCamelCase(child.localName(), true) + "Config";
			}
			if (propertyName != null) {
				config[propertyName] = childObj;
			} else {
				var f:Function = config[methodName];
				f.apply(config, [childObj]);
			}
		}		
	}
	
	
	private function convertXmlToCamelCase (id:String, convertFirst:Boolean) : String {
		// change names from "two-chunks" to "twoChunks" or "TwoChunks"
		if (convertFirst) id = id.charAt(0).toUpperCase() + id.substring(1);
		if (id.indexOf("-") == -1) return id;
		var chunks:Array = id.split("-");
		var conv:String = chunks[0];
		for (var i:Number = 1; i < chunks.length; i++) {
			var chunk:String = chunks[i];
			conv += chunk.charAt(0).toUpperCase() + chunk.substring(1);
		}
		return conv;
	}	
	
}

}