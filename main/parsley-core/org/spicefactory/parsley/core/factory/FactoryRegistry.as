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

package org.spicefactory.parsley.core.factory {

/**
 * @author Jens Halm
 */
public interface FactoryRegistry {
	
	
	function get contextBuilder () : ContextBuilderFactory;
	
	function set contextBuilder (value:ContextBuilderFactory) : void;

	function get context () : ContextFactory;

	function set context (value:ContextFactory) : void;

	function get lifecycleManager () : ObjectLifecycleManagerFactory;

	function set lifecycleManager (value:ObjectLifecycleManagerFactory) : void;

	function get definitionRegistry () : ObjectDefinitionRegistryFactory;

	function set definitionRegistry (value:ObjectDefinitionRegistryFactory) : void;

	function get viewManager () : ViewManagerFactory;

	function set viewManager (value:ViewManagerFactory) : void;

	function get messageRouter () : MessageRouterFactory;

	function set messageRouter (value:MessageRouterFactory) : void;

	
}
}
