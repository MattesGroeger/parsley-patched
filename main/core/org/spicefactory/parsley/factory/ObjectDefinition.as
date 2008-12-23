/*
 * Copyright 2008-2009 the original author or authors.
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

package org.spicefactory.parsley.factory {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Method;
import org.spicefactory.parsley.factory.registry.MethodRegistry;
import org.spicefactory.parsley.factory.registry.ConstructorArgRegistry;
import org.spicefactory.parsley.factory.registry.PostProcessorRegistry;
import org.spicefactory.parsley.factory.registry.PropertyRegistry;

/**
 * @author Jens Halm
 */
public interface ObjectDefinition {
	
	
	function get type () : ClassInfo;

	
	function get constructorArgs () : ConstructorArgRegistry;
	
	function get properties () : PropertyRegistry;
	
	function get injectorMethods () : MethodRegistry;


	function get postProcessors () : PostProcessorRegistry;	
	
	
	function get initMethod () : Method;
	
	function set initMethod (value:Method) : void;
	
	
	function get destroyMethod () : Method;
	
	function set destroyMethod (value:Method) : void;
	
	
	function freeze () : void;

	
}

}
