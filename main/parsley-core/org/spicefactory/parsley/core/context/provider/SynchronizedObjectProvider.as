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

package org.spicefactory.parsley.core.context.provider {

/**
 * ObjectProvider extension that allows to add a callback to be invoked when
 * the provided object gets removed from the Context.
 * 
 * @author Jens Halm
 */
public interface SynchronizedObjectProvider extends ObjectProvider {
	
	
	/**
	 * Adds a callback to be invoked when
 	 * the provided object gets removed from the Context.
 	 * The specified parameters will be passed to the handler.
 	 * The provider itself will not be added to the parameters
 	 * since it is not used in most cases when cleaning up.
 	 * 
 	 * @param handler the handler to be invoked when
 	 * the provided object gets removed from the Context
 	 * @param params the parameters to be passed to the handler
	 */
	function addDestroyHandler (handler:Function, ...params) : void;
	
	
}
}
