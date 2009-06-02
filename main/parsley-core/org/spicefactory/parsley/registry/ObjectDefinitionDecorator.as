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

package org.spicefactory.parsley.registry {

	import org.spicefactory.parsley.registry.ObjectDefinitionRegistry;
/**
 * The core extension interface for adding configuration artifacts to an object definition.
 * 
 * <p>All builtin configuration tags like <code>[Inject]</code> or <code>[MessageHandler]</code>
 * implement this interface. But it can also be used to create custom configuration tags.
 * Parsleys flexibility makes it possible that in most cases implementations of this interface
 * can used as Metadata, MXML and XML tag.</p>
 * 
 * <p>For details see 
 * <a href="http://www.spicefactory.org/parsley/docs/2.0/manual?page=extensions&section=decorators>11.2 Creating Custom Configuration Tags</a>
 * in the Parsley Manual.</p>
 * 
 * @author Jens Halm
 */
public interface ObjectDefinitionDecorator {
	
	/**
	 * Method to be invoked by the container for each configuration tag it encounters for an object 
	 * that was added to the container. It doesn't matter whether it is a builtin configuration tag 
	 * or a custom extension tag, or whether it is a metadata tag, an MXML or XML tag. 
	 * As long as the tag is mapped to a class that implements this interface the container 
	 * will invoke it for each tag on each object.
	 * 
	 * <p>The definition parameter it passes to the decorator is the ObjectDefinition that it currently processes. 
	 * In most custom tag implementations you will modify this definition, specifying constructor arguments, 
	 * property values, object lifecycle listeners or instantiators.
 	 * The second parameter is the ObjectDefinitionRegistry currently under construction. 
 	 * In most cases you'll just ignore this parameter, but under certain circumstances your custom tag may wish 
 	 * to create new definitions (in addition to the one it modifies) and add them to the registry. 
 	 * Those additional definitions might describe collaborators that the modified definition will need 
 	 * to operate for example. Of course you should check if this collaborator has been already added 
 	 * as the custom tag may be placed on multiple objects.</p>
 	 * 
	 * <p>Finally this method has to return an ObjectDefinition. 
	 * In most cases this will be the same instance that was passed to the decorate method. 
	 * But you are allowed to replace it with a completely new definition instance. 
	 * Since ObjectDefinition is an interface it may even be a custom definition implementation. 
	 * But in such a case you should make sure that you copy the configuration artifacts 
	 * already added to the definition as other tags may have already processed this definition.</p>
	 */
	function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition;
	
}

}