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

package org.spicefactory.parsley.factory.registry.impl {
import org.spicefactory.parsley.factory.ObjectDefinition;
import org.spicefactory.parsley.factory.ObjectPostProcessor;
import org.spicefactory.parsley.factory.registry.PostProcessorEntry;
import org.spicefactory.parsley.factory.registry.PostProcessorRegistry;

/**
 * @author Jens Halm
 */
public class DefaultPostProcessorRegistry extends AbstractRegistry implements PostProcessorRegistry {


	private var processors:Array = new Array();


	function DefaultPostProcessorRegistry (def:ObjectDefinition) {
		super(def);
	}

	
	public function addPostProcessor (processor:ObjectPostProcessor, afterInit:Boolean = false) : PostProcessorRegistry {
		checkState();
		processors.push(new PostProcessorEntry(processor, afterInit));
		return this;
	}
	
	public function removePostProcessor (processor:ObjectPostProcessor) : PostProcessorRegistry {
		checkState();
		for (var i:uint = 0; i < processors.length; i++) {
			var entry:PostProcessorEntry = PostProcessorEntry(processors[i]);
			if (entry.processor = processor) {
				processors.slice(i,1);
			}
		}
		return this;
	}
	
	public function getAll () : Array {
		return processors.concat();
	}
	
	
}

}
