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

package org.spicefactory.parsley.tag.lifecycle {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.core.context.provider.SynchronizedObjectProvider;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.ScopeName;

import flash.system.ApplicationDomain;

/**
 * Abstract base class for tags that need to handle ObjectProviders, like tags for message receivers or
 * lifecycle observers.
 * 
 * <p>It is recommended that subclasses simply override the (pseudo-)abstract methods
 * <code>handleProvider</code> and (optionally) <code>validate</code> instead of implementing
 * the <code>decorate</code> method itself, since this base class already does some
 * of the plumbing.</p>
 * 
 * @author Jens Halm
 */
public class AbstractSynchronizedProviderDecorator implements ObjectDefinitionDecorator {
	
	
	/**
	 * The name of the scope this tag should be applied to.
	 */
	public var scope:String = ScopeName.GLOBAL;
	
	/**
	 * The ApplicationDomain to use for reflection.
	 */
	protected var domain:ApplicationDomain;
	
	/**
	 * The scope instance this tag should be applied to.
	 */
	protected var targetScope:Scope;
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : ObjectDefinition {
		validate(definition, registry);
		domain = registry.domain;
		targetScope = registry.context.scopeManager.getScope(scope);
		definition.objectLifecycle.synchronizeProvider(handleProvider);
		return definition;
	}
	
	/**
	 * Validates this tag instance and should throw an error in case of configuration issues.
	 * This method will be invoke on Context creation time and allows for fail-fast behaviour.
	 * 
	 * @param definition the definition currently processed
	 * @param registry the registry the definition belongs to
	 */
	protected function validate (definition:ObjectDefinition, registry:ObjectDefinitionRegistry) : void {
		/* do nothing */
	}
	
	/**
	 * Handles the specified provider, using it for tasks like message receiver or lifecycle listener
	 * registration. The time this method gets invoked depends on the type of object.
	 * For non-lazy singletons this happens even before the actual instance is created, for other types
	 * of objects when the object gets instantiated.
	 * 
	 * <p>For non-singleton configurations this method may be invoked multiple times for the same tag instance.</p>
	 * 
	 * @param provider the provider for an instance produced by the definition processed by this decorator
	 */
	protected function handleProvider (provider:SynchronizedObjectProvider) : void {
		throw new AbstractMethodError();
	}
	
	
}
}
