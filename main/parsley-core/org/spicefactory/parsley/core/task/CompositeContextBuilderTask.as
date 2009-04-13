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

package org.spicefactory.parsley.core.task {
import org.spicefactory.lib.task.SequentialTaskGroup;
import org.spicefactory.parsley.core.CompositeContextBuilder;
import org.spicefactory.parsley.core.Context;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class CompositeContextBuilderTask extends SequentialTaskGroup {

	
	private var _builder:CompositeContextBuilder;
	private var _result:Context;
	
	
	function CompositeContextBuilderTask (parent:Context = null, domain:ApplicationDomain = null) {
		_builder = new CompositeContextBuilder(parent, domain);
	}
	
	
	public function get builder () : CompositeContextBuilder {
		return _builder;
	}
	
	public function get result () : Context {
		return _result;
	}

	
	protected override function complete () : Boolean {
		try {
			_result = _builder.build();
			return super.complete();
		}
		catch (e:Error) {
			error(e.message);
			return false;
		}
	}
	
	
}

}
