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
 
package org.spicefactory.parsley.context.factory {
	
import org.spicefactory.parsley.context.ApplicationContext;
	
/**
 * Interface to be implemented by all configuration classes that represent a single XML node.
 * 
 * @author Jens Halm
 */
public interface ElementConfig {

	/**
	 * Parses the specified XML node.
	 * 
	 * @param node the XML node to parse
	 * @param context the ApplicationContext this configuration instance belongs to
	 */
	function parse (node:XML, context:ApplicationContext) : void;
		
}

}