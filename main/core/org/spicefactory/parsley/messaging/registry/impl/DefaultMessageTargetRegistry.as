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

package org.spicefactory.parsley.messaging.registry.impl {
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.registry.impl.AbstractRegistry;
import org.spicefactory.parsley.messaging.MessageTargetDefinition;
import org.spicefactory.parsley.messaging.registry.MessageTargetRegistry;

/**
 * @author Jens Halm
 */
public class DefaultMessageTargetRegistry extends AbstractRegistry implements MessageTargetRegistry {


	private var targets:Array = new Array();


	function DefaultMessageTargetRegistry (def:ObjectDefinition) {
		super(def);
	}

	
	public function addMessageTarget (target:MessageTargetDefinition) : MessageTargetRegistry {
		checkState();
		targets.push(target);
		return this;
	}
	
	public function removeMessageTarget (target:MessageTargetDefinition) : MessageTargetRegistry {
		checkState();
		var index:int = targets.indexOf(target);
		if (index != -1) targets.slice(index, 1);
		return this;
	}
	
	public function getAll () : Array {
		return targets.concat();
	}


}

}
