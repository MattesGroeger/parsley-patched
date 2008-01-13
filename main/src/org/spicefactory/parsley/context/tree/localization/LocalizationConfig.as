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
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.ns.context_internal;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.tree.ApplicationContextAware;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.localization.impl.DefaultLocaleManager;
import org.spicefactory.parsley.localization.impl.DefaultMessageSource;
import org.spicefactory.parsley.localization.spi.LocaleManagerSpi;
import org.spicefactory.parsley.localization.spi.MessageSourceSpi;

/**
 * Represents the <code>localization</code> tag.
 * 
 * @author Jens Halm
 */
public class LocalizationConfig 
		extends AbstractElementConfig implements ApplicationContextAware {
	
	
	use namespace context_internal;
	
	private var _context:ApplicationContext;
	
	private var _messageSourceConfig:MessageSourceConfig;
	private var _localeManagerConfig:LocaleManagerConfig;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addChildNode("locale-manager", LocaleManagerConfig, [], 0, 1);
			ep.addChildNode("message-source", MessageSourceConfig, [], 0, 1);
			_elementProcessor = ep;
		}
		return _elementProcessor;
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
	
	public function set messageSourceConfig (msc:MessageSourceConfig) : void {
		if (_messageSourceConfig == null) {
			_messageSourceConfig = msc;
		} else {
			_messageSourceConfig.merge(msc);
		}
	}
	/**
	 * The configuration for the <code>MessageSource</code>.
	 */
	public function get messageSourceConfig () : MessageSourceConfig {
		return _messageSourceConfig;
	}
	
	public function set localeManagerConfig (lmc:LocaleManagerConfig) : void {
		if (_localeManagerConfig != null) {
			throw new ConfigurationError("More than one LocaleManager was specified");
		}
		_localeManagerConfig = lmc;
	}
	/**
	 * The configuration for the <code>LocaleManager</code>.
	 * There is only one active <code>LocaleManager</code> in each application, so
	 * usually this configuration should only be included with the root <code>ApplicationContext</code>.
	 */
	public function get localeManagerConfig () : LocaleManagerConfig {
		return _localeManagerConfig;
	}
	
	/**
	 * Merges the content of another localization configuration with the content of this instance.
	 * 
	 * @param vc the localization configuration to merge with this instance
	 */
	public function merge (ic:LocalizationConfig) : void {
		messageSourceConfig = ic.messageSourceConfig;
		localeManagerConfig = ic.localeManagerConfig;
	}
	
	/**
	 * Processes this configuration and instantiates the <code>MessageSource</code> and
	 * <code>LocaleManager</code> instances.
	 */
	public function process () : void {
		processLocaleManager();
		processMessageSource();
	}
	
	
	private function processLocaleManager () : void {
		var lm:LocaleManagerSpi;
		if (ApplicationContext.localeManager != null) {
			if (_localeManagerConfig != null) {
				throw new ConfigurationError("locale-manager tag can only be included in first ApplicationContext");
			}
			return;
		}
		if (_localeManagerConfig != null) {
			lm = _localeManagerConfig.createLocaleManager();
		} else {
			lm = new DefaultLocaleManager();
		}
		ApplicationContext.setLocaleManager(lm);
	}
	
	
	private function processMessageSource () : void {
		var ms:MessageSourceSpi;
		if (_messageSourceConfig != null) {
			ms = _messageSourceConfig.createMessageSource();
		} else {
			ms = new DefaultMessageSource();
		}
		_context.setMessageSource(ms);
		if (_context.parent != null) {
			var pms:MessageSourceSpi = MessageSourceSpi(_context.parent.messageSource);
			pms.addChild(ms);
			ms.parent = pms;
		}
	}
	
	
	
}

}