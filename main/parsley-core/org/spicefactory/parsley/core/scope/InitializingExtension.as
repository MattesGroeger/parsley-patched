/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.parsley.core.scope {

/**
 * Interface to be implemented by scope extensions that need access
 * to the Scope instance they are associated with.
 * 
 * @author Jens Halm
 */
public interface InitializingExtension {
	
	
	/**
	 * Invoked once after the extension has been instantiated.
	 * The Scope instance passed to this method represents the scope that
	 * this extension is associated with.
 	 * 
 	 * @param scope the scope this extension is associated with
	 */
	function init (scope:Scope) : void;
	
	
}
}