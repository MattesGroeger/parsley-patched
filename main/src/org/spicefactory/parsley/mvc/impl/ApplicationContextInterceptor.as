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
 
package org.spicefactory.parsley.mvc.impl {
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.mvc.ActionInterceptor;
import org.spicefactory.parsley.mvc.ActionProcessor;

/**
 * An <code>ActionInterceptor</code> implementation that serves as 
 * a registration for a lazily initialized <code>ActionInterceptor</code> delegate configured in an
 * <code>ApplicationContext</code>.
 * 
 * @author Jens Halm
 */
public class ApplicationContextInterceptor implements ActionInterceptor {
	
	
	private var _delegate:ActionInterceptor;
	
	private var context:ApplicationContext;
	private var objectId:String;
	
	
	/**
	 * Creates a new instance.
	 * 
	 * @param context the context containing the interceptor
	 * @param objectId the id of the interceptor in the context
	 */
	function ApplicationContextInterceptor (context:ApplicationContext, objectId:String) {
		this.context = context;
		this.objectId = objectId;
	}
	
	
	private function get delegate () : ActionInterceptor {
		if (_delegate == null) {
			_delegate = createInterceptor();
		}
		return _delegate;
	}
	
	private function createInterceptor () : ActionInterceptor {
		var ic:Object = context.getObject(objectId);
		if (ic == null) {
			throw new ConfigurationError("No object registered with id " + objectId);
		}
		if (!ic is ActionInterceptor) {
			throw new ConfigurationError("Object with id " + objectId 
				+ " does not implement ActionInterceptor");
		}
		return ic as ActionInterceptor;
	}
	
	/**
	 * @inheritDoc
	 */
	public function intercept (processor:ActionProcessor) : void {
		delegate.intercept(processor);
	}
	
	
}

}
