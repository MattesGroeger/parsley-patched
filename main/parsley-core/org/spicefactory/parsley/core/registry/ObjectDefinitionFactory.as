/*
 * Copyright 2009 the original author or authors.
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

package org.spicefactory.parsley.core.registry {

[ExcludeClass]

/**
 * @private
 * 
 * Deprecated. Kept in the code base for backwards-compatibility.
 * The builders accessible through registry.builders should now be used.
 * This class only delegates to the new mechanism now.
 * For root object tags the new interface RootConfigurationTag can now be used.
 * For nested object tags use ResolvableRegistryValue
 * 
 * @author Jens Halm
 */
public interface ObjectDefinitionFactory {
	
	function createRootDefinition (registry:ObjectDefinitionRegistry) : RootObjectDefinition;	

	function createNestedDefinition (registry:ObjectDefinitionRegistry) : ObjectDefinition;	
	
}
}
