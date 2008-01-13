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
 
package org.spicefactory.parsley.localization {

/**	
 * The central repository for localized messages. 
 * Manages multiple <code>MessageBundle</code> instances.
 * 
 * @author Jens Halm
 */
public interface MessageSource {
	
	/**
	 * Indicates whether bundles managed by this instance should be cached.
	 * If this property is set to false all bundles will be reloaded each time
	 * the current <code>Locale</code> is switched.
	 */
	function get cacheable () : Boolean;
	
	function set cacheable (cacheable:Boolean) : void;
	
	/**
	 * Returns the message bundle for the specified id.
	 * If the id parameter is omitted the default bundle will be returned.
	 * 
	 * @param bundleId the id of the message bundle
	 * @return the message bundle with the specified id or null if no such bundle exists
	 */
	function getBundle (bundleId:String = null) : MessageBundle;
	
	/**
	 * @copy org.spicefactory.parsley.context.ApplicationContext#getMessage()
	 */
	function getMessage (messageKey:String, bundleId:String = null, params:Array = null) : String;
		
}

}