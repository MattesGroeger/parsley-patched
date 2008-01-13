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
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;
import org.spicefactory.parsley.localization.Locale;

/**
 * The configuration for a single <code>Locale</code>.
 * 
 * @author Jens Halm
 */
public class LocaleConfig  
		extends AbstractElementConfig {
	
	
	private var _language:String;
	private var _country:String;
	
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("language", StringConverter.INSTANCE, false, "");
			ep.addAttribute("country", StringConverter.INSTANCE, false, "");
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}	
	
	
	/**
	 * Creates a new instance.
	 */
	function LocaleConfig () {
		
	}
	
	/**
	 * @copy org.spicefactory.parsley.localization.Locale#language
	 */
	public function get language () : String {
		if (_language != null) {
			return _language;
		} else {
			return getAttributeValue("language");
		}
	}
	
	public function set language (language:String) : void {
		_language = language;
	}
	
	/**
	 * @copy org.spicefactory.parsley.localization.Locale#country
	 */
	public function get country () : String {
		if (_country != null) {
			return _country;
		} else {
			return getAttributeValue("country");
		}
	}
	
	public function set country (country:String) : void {
		_country = country;
	}
	
	/**
	 * Creates a new <code>Locale</code> instance for this configuration.
	 */
	public function create () : Locale {
		return new Locale(language, country);
	}
	
	
	
}

}