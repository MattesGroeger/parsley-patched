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
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.util.BooleanValue;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.localization.impl.DefaultBundleLoaderFactory;
import org.spicefactory.parsley.localization.impl.DefaultMessageBundle;
import org.spicefactory.parsley.localization.spi.BundleLoaderFactory;
import org.spicefactory.parsley.localization.spi.MessageBundleSpi;

/**
 * Represents the <code>MessageBundle</code> - in XML configuration the 
 * <code>&lt;message-bundle&gt;</code> tag. 
 * 
 * @author Jens Halm
 */
public class MessageBundleConfig 
		extends AbstractElementConfig {
	
	
	private var _id:String;
	private var _basename:String;
	private var _localized:BooleanValue;
	private var _ignoreCountry:BooleanValue;
	
	private var _bundleClass:ClassInfo;
	private var _loaderFactory:ClassInfo;
	
	private var _sourceConfig:MessageSourceConfig;
	
	

	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var bundleReqType:ClassInfo = ClassInfo.forClass(MessageBundleSpi);
			var loaderReqType:ClassInfo = ClassInfo.forClass(BundleLoaderFactory);
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("id", StringConverter.INSTANCE, true);
			ep.addAttribute("basename", StringConverter.INSTANCE, true);
			ep.addAttribute("localized", BooleanConverter.INSTANCE, false, false);
			ep.addAttribute("ignore-country", BooleanConverter.INSTANCE, false, false);
			ep.addAttribute("type",  new ClassInfoConverter(bundleReqType), false);
			ep.addAttribute("loader-factory", new ClassInfoConverter(loaderReqType), false);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}	
	
	
	/**
	 * Creates a new instance.
	 */
	function MessageBundleConfig () {

	}
	
	/**
	 * @private
	 */
	internal function set sourceConfig (config:MessageSourceConfig) : void {
		if (_sourceConfig != null) {
			// do not overwrite existing value when merging multiple files
			return;
		}
		_sourceConfig = config;
	}
	
	/**
	 * The id of the bundle.
	 */
	public function get id () : String {
		if (_id != null) {
			return _id;
		} else {
			return getAttributeValue("id");
		}
	}
	
	public function set id (id:String) : void {
		_id = id;
	}
	
	/**
	 * The basename of files containing messages for this bundle.
	 */
	public function get basename () : String {
		if (_basename != null) {
			return _basename;
		} else {
			return getAttributeValue("basename");
		}
	}
	
	public function set basename (basename:String) : void {
		_basename = basename;
	}
	
	/**
	 * Indicates whether messages for this bundle are localized.
	 */
	public function get localized () : Boolean {
		if (_localized != null) {
			return _localized.value;
		} else {
			return getAttributeValue("localized");
		}
	}
	
	public function set localized (value:Boolean) : void {
		_localized = new BooleanValue(value);
	} 
	
	/**
	 * Indicates whether the country code of the active Locale should be ignored
	 * when loading new messages for this bundle.
	 */
	public function get ignoreCountry () : Boolean {
		if (_ignoreCountry != null) {
			return _ignoreCountry.value;
		} else {
			return getAttributeValue("ignoreCountry");
		}
	}
	
	public function set ignoreCountry (value:Boolean) : void {
		_ignoreCountry = new BooleanValue(value);
	} 
	
	public function set type (config:ClassInfo) : void {
		_bundleClass = config;
	} 
	
	/**
	 * The class to instantiate (must implement <code>MessageBundleSpi</code>.
	 */
	public function get type () : ClassInfo {
		if (_bundleClass != null) {
			return _bundleClass;
		} else {
			var ci:ClassInfo = getAttributeValue("type");
			return (ci == null) ? _sourceConfig.bundleType : ci;
		}
	}
	
	public function set loaderFactory (config:ClassInfo) : void {
		_loaderFactory = config;
	} 
	
	/**
	 * The <code>BundleLoaderFactory</code> implementation class
	 * to use for loading message bundles. 
	 * The default implementation will
	 * load messages from XML files.
	 */
	public function get loaderFactory () : ClassInfo {
		if (_loaderFactory != null) {
			return _loaderFactory;
		} else {
			var ci:ClassInfo = getAttributeValue("loaderFactory");
			return (ci == null) ? _sourceConfig.loaderFactory : ci;
		}
	}
	
	/**
	 * Processes this configuration and instantiates a MessageBundle.
	 * 
	 * @param defaultBundleClass the class to use for the message bundle if none is explicitly specified
	 * in this configuration
	 * @param defaultLoaderFactory the class to use for the loader factory if none is explicitly 
	 * specified in this configuration
	 * @return a new MessageBundle instance
	 */
	public function createBundle (defaultBundleClass:ClassInfo, 
			defaultLoaderFactory:ClassInfo) : MessageBundleSpi {
		
		// create bundle
		var bundle:MessageBundleSpi;
		if (type != null) {
			bundle = MessageBundleSpi(type.newInstance([]));
		} else if (defaultBundleClass != null) {
			bundle = MessageBundleSpi(defaultBundleClass.newInstance([]));
		} else {
			 bundle = new DefaultMessageBundle();
		}
		bundle.init(id, basename, localized, ignoreCountry);
		
		// create loader factory
		var factory:BundleLoaderFactory;
		if (loaderFactory != null) {
			factory = BundleLoaderFactory(loaderFactory.newInstance([]));
		} else if (defaultLoaderFactory != null) {
			factory = BundleLoaderFactory(defaultLoaderFactory.newInstance([]));
		} else {
			factory = new DefaultBundleLoaderFactory();
		}
		bundle.bundleLoaderFactory = factory;
		
		return bundle;
	}
	
	
}

}