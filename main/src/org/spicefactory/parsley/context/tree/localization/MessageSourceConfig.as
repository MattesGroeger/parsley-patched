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
 
package org.spicefactory.parsley.context.tree.localization {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.BooleanConverter;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.util.collection.SimpleMap;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.util.BooleanValue;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.localization.impl.DefaultBundleLoaderFactory;
import org.spicefactory.parsley.localization.impl.DefaultMessageBundle;
import org.spicefactory.parsley.localization.impl.DefaultMessageSource;
import org.spicefactory.parsley.localization.spi.BundleLoaderFactory;
import org.spicefactory.parsley.localization.spi.MessageBundleSpi;
import org.spicefactory.parsley.localization.spi.MessageSourceSpi;

/**
 * Represents the <code>MessageSource</code> - in XML configuration the 
 * <code>&lt;message-source&gt;</code> tag. 
 * 
 * @author Jens Halm
 */
public class MessageSourceConfig  
		extends AbstractElementConfig {
	
	
	private var _Class:ClassInfo;
	private var _defaultBundleClass:ClassInfo;
	private var _defaultLoaderFactory:ClassInfo;
	private var _cacheable:BooleanValue;
	private var _defaultMessageBundleConfig:MessageBundleConfig;
	private var _messageBundleConfigs:SimpleMap;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var sourceDefType:ClassInfo = ClassInfo.forClass(DefaultMessageSource);
			var sourceReqType:ClassInfo = ClassInfo.forClass(MessageSourceSpi);
			var bundleDefType:ClassInfo = ClassInfo.forClass(DefaultMessageBundle);
			var bundleReqType:ClassInfo = ClassInfo.forClass(MessageBundleSpi);
			var loaderDefType:ClassInfo = ClassInfo.forClass(DefaultBundleLoaderFactory);
			var loaderReqType:ClassInfo = ClassInfo.forClass(BundleLoaderFactory);
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("default-message-bundle", MessageBundleConfig, [], 0, 1);
			ep.addChildNode("message-bundle", MessageBundleConfig, [], 0);
			ep.addAttribute("type", new ClassInfoConverter(sourceReqType), false, sourceDefType);
			ep.addAttribute("cacheable", BooleanConverter.INSTANCE, false, false);
			ep.addAttribute("bundle-type", new ClassInfoConverter(bundleReqType), false, bundleDefType);
			ep.addAttribute("loader-factory", new ClassInfoConverter(loaderReqType), false, loaderDefType);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}	
	
	
	/**
	 * Creates a new instance.
	 */
	function MessageSourceConfig () {
		_messageBundleConfigs = new SimpleMap();
	}
	
	/**
	 * The class to instantiate (must implement <code>MessageSourceSpi</code>.
	 */
	public function get type () : ClassInfo {
		if (_Class != null) {
			return _Class;
		} else {
			return getAttributeValue("type");
		}
	}
	
	public function set type (config:ClassInfo) : void {
		_Class = config;
	}
	
	/**
	 * Indicates whether loaded bundles should be cached.
	 * When this attribute is set to <code>true</code> all loaded bundles will be
	 * cached when you switch to a different locale. 
	 * If you set this to <code>false</code> (the default) all bundles
	 * will be reloaded when you switch the active locale.
	 */
	public function get cacheable () : Boolean {
		if (_cacheable != null) {
			return _cacheable.value;
		} else {
			return getAttributeValue("cacheable");
		}
	}
	
	public function set cacheable (value:Boolean) : void {
		_cacheable = new BooleanValue(value);
	}
	
	/**
	 * The <code>MessageBundle</code> implementation class to use
	 * for bundles declared with the <code>message-bundle</code> child tag. 
	 * Usually the default builtin implementation is sufficient.
	 */
	public function get bundleType () : ClassInfo {
		if (_defaultBundleClass != null) {
			return _defaultBundleClass;
		} else {
			return getAttributeValue("bundleType");
		}
	}
	
	public function set bundleType (config:ClassInfo) : void {
		_defaultBundleClass = config;
	}
	
	/**
	 * The <code>BundleLoaderFactory</code> implementation class
	 * to use for loading message bundles. 
	 * The default implementation will
	 * load messages from XML files.
	 */
	public function get loaderFactory () : ClassInfo {
		if (_defaultLoaderFactory != null) {
			return _defaultLoaderFactory;
		} else {
			return getAttributeValue("loaderFactory");
		}
	}
	
	public function set loaderFactory (config:ClassInfo) : void {
		_defaultLoaderFactory = config;
	}
	
	public function set defaultMessageBundleConfig (config:MessageBundleConfig) : void {
		if (_defaultMessageBundleConfig != null) {
			throw new ConfigurationError("More than one default-message-bundle was specified");
		}
		addMessageBundleConfig(config);
		_defaultMessageBundleConfig = config;
	}
	
	/**
	 * The configuration for the default message bundle.
	 */
	public function get defaultMessageBundleConfig () : MessageBundleConfig {
		return _defaultMessageBundleConfig;
	}
	
	/**
	 * Adds the configuration for a single message bundle.
	 * 
	 * @param config the message bundle to add to this configuration
	 */
	public function addMessageBundleConfig (config:MessageBundleConfig) : void {
		if (_messageBundleConfigs.containsKey(config.id)) {
			throw new ConfigurationError("Duplicate Message Bundle Id: " + config.id);
		}
		config.sourceConfig = this;
		_messageBundleConfigs.put(config.id, config);
	}
	
	/**
	 * Merges the content of another message source configuration with the content of this instance.
	 * 
	 * @param msc the message source configuration to merge with this instance
	 */
	public function merge (msc:MessageSourceConfig) : void {
		defaultMessageBundleConfig = msc.defaultMessageBundleConfig;
		for each (var config:MessageBundleConfig in msc._messageBundleConfigs) {
			addMessageBundleConfig(config);
		}
		/* ignore cacheable and class attribute */
	}
	
	/**
	 * Processes the configuration and instantiates a <code>MessageSource</code>.
	 * 
	 * @return a new MessageSource instance
	 */
	public function createMessageSource () : MessageSourceSpi {
		// create instance
		var obj:Object = type.newInstance([]);
		// configure instance
		var impl:MessageSourceSpi = MessageSourceSpi(obj);
		impl.cacheable = cacheable;
		for each (var config:MessageBundleConfig in _messageBundleConfigs.values) {
			var bundle : MessageBundleSpi = config.createBundle(bundleType, loaderFactory);
			if (config == _defaultMessageBundleConfig) {
				impl.defaultBundle = bundle;
			} else {
				impl.addBundle(bundle);
			}
		}
		return impl;
	}
	
	
	
}

}