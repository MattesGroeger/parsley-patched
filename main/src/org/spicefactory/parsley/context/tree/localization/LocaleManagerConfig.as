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
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.util.BooleanValue;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.localization.LocaleManager;
import org.spicefactory.parsley.localization.impl.DefaultLocaleManager;
import org.spicefactory.parsley.localization.spi.LocaleManagerSpi;

/**
 * Represents the <code>LocaleManager</code> - in XML configuration the 
 * <code>&lt;locale-manager&gt;</code> tag. 
 * 
 * @author Jens Halm
 */
public class LocaleManagerConfig  
		extends AbstractElementConfig implements ApplicationContextAware {


	private var _context:ApplicationContext;
	private var _Class:ClassInfo;
	private var _persistent:BooleanValue;
	private var _defaultLocaleConfig:LocaleConfig;
	private var _localeConfigs:Array;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			var defType:ClassInfo = ClassInfo.forClass(DefaultLocaleManager);
			var reqType:ClassInfo = ClassInfo.forClass(LocaleManagerSpi);
			ep.addChildNode("default-locale", LocaleConfig, [], 0, 1);
			ep.addChildNode("locale", LocaleConfig, [], 0);
			ep.addAttribute("type", new ClassInfoConverter(reqType, domain), false, defType);
			ep.addAttribute("persistent", BooleanConverter.INSTANCE, false, false);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}	
	
	
	
	function LocaleManagerConfig () {
		_localeConfigs = new Array();
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
	
	/**
	 * The class to instantiate (must implement <code>LocaleManagerSpi</code>.
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
	 * Indicates whether the <code>LocaleManager</code> should store the
	 * active Locale in a Local Shared Object.
	 */
	public function get persistent () : Boolean {
		if (_persistent != null) {
			return _persistent.value;
		} else {
			return getAttributeValue("persistent");
		}
	}
	
	public function set persistent (value:Boolean) : void {
		_persistent = new BooleanValue(value);
	}
	
	/**
	 * The default Locale to use at application startup.
	 */
	public function set defaultLocaleConfig (config:LocaleConfig) : void {
		_defaultLocaleConfig = config;
	}
	
	public function addLocaleConfig (config:LocaleConfig) : void {
		_localeConfigs.push(config);
	}
	
	/**
	 * Processes this configuration and instantiates a <code>LocaleManager</code>.
	 * 
	 * @return a new <code>LocaleManager</code> instance.
	 */
	public function createLocaleManager () : LocaleManagerSpi {
		// create instance
		var obj:Object = type.newInstance([]);
		// configure instance
		var impl:LocaleManagerSpi = LocaleManagerSpi(obj);
		impl.persistent = persistent;
		if (_defaultLocaleConfig != null) {
			impl.defaultLocale = _defaultLocaleConfig.create();
		}
		for each (var lc:LocaleConfig in _localeConfigs) {
			impl.addSupportedLocale(lc.create());
		}
		return impl;
	}
	
	
	
}

}