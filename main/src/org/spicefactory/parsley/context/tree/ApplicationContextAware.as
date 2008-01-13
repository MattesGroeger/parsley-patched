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
 
package org.spicefactory.parsley.context.tree {

import org.spicefactory.parsley.context.ApplicationContext;
	

/**
 * Interfaces to be implemented by all configuration classes that need a reference
 * to the <code>ApplicationContext</code> they belong to.
 * 
 * @author Jens Halm
 */
public interface ApplicationContextAware {

	/**
	 * The application context this configuration object belongs to.
	 */
	function get applicationContext () : ApplicationContext;
	
	function set applicationContext (context:ApplicationContext) : void;
		
}

}