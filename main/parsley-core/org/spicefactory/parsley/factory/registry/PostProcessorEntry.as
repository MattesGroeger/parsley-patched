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

package org.spicefactory.parsley.factory.registry {
import org.spicefactory.parsley.factory.ObjectPostProcessor;

/**
 * @author Jens Halm
 */
public class PostProcessorEntry {
	
	
	private var _processor:ObjectPostProcessor;
	private var _afterInit:Boolean;
	
	
	function PostProcessorEntry (processor:ObjectPostProcessor, afterInit:Boolean) {
		_processor = processor;
		_afterInit = afterInit;
	}

	
	public function get processor () : ObjectPostProcessor {
		return _processor;
	}
	
	public function get afterInit () : Boolean {
		return _afterInit;
	}

	
}

}
