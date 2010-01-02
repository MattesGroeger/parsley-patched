/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.tag {
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;

/**
 * Represent a root configuration tag in MXML or XML configuration files.
 * 
 * @author Jens Halm
 */
public interface RootConfigurationTag {
	
	/**
	 * Processes this configuration tag, possilbly adding object definitions to the specified registry.
	 * 
	 * @param registry the registry to process
	 */
	function process (registry:ObjectDefinitionRegistry) : void;
	
}
}
