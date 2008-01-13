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
 
package org.spicefactory.parsley.context.tree.values {
import org.spicefactory.lib.util.Command;
import org.spicefactory.parsley.context.binding.MessageBinding;	

/**
 * Represents a binding to a localized message from a message bundle 
 * - in XML configuration the &lt;message-binding&gt; tag. The value for this
 * message binding will be automatically refreshed each time the locale is switched. 
 * 
 * @author Jens Halm
 */
public class MessageBindingConfig 
		extends MessageConfig implements BoundValueConfig {
	
	
	/**
	 * Creates a new instance.
	 */
	function MessageBindingConfig () {
		super();
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function bind (target:Object, property:String) : Command {
		var bind:MessageBinding = new MessageBinding(applicationContext, key, bundle);
		if (paramArrayConfig != null) {
			bind.parameters = paramArrayConfig.value;
		} else if (paramMethodConfig != null) {
			bind.parameterCommand = paramMethodConfig.createCommand();
		}
		bind.bind(target, property);
		return new Command(bind.unbind, []);
	} 
	
	
}

}