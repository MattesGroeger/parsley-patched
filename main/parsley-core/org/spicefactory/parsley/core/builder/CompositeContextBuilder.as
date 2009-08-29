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

package org.spicefactory.parsley.core.builder {
import org.spicefactory.parsley.core.context.Context;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public interface CompositeContextBuilder {
	
	/**
	 * Adds an ObjectDefinitionBuilder.
	 * 
	 * @param builder the builder to add
	 */
	function addBuilder (builder:ObjectDefinitionBuilder) : void;
	
	/**
	 * The ApplicationDomain this builder uses for reflection.
	 */
	function get domain () : ApplicationDomain;
	
	/**
	 * The Context built by this instance, possibly still under construction.
	 */
	function get context () : Context;
	
	/**
	 * Builds the Context, using all definition builders that were added with the addBuilder method.
	 * The returned Context instance may not be fully initialized if it requires asynchronous operations.
	 * You can check its state with its <code>configured</code> and <code>initialized</code> properties.
	 * 
	 * @return a new Context instance, possibly not fully initialized yet
	 */
	function build () : Context;
	
}
}
