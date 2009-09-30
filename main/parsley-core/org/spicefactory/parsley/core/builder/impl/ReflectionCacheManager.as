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

package org.spicefactory.parsley.core.builder.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.events.ContextEvent;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Manages the inherited scopes for all currently active Context instances.
 * This is an internal class that usually should only be used by custom
 * CompositeContextBuilder implementations. It is necessary since some
 * internal objects like the 2 shared MessageRouter instances that each
 * Scope manages are not accessible through the public Scope API.
 * 
 * @author Jens Halm
 */
public class ReflectionCacheManager {
	
	
	private static const log:Logger = LogContext.getLogger(ReflectionCacheManager);
	
	
	private static const domainCounter:Dictionary = new Dictionary();
	private static const contextMap:Dictionary = new Dictionary();
	
	
	public static function addDomain (context:Context, domain:ApplicationDomain) : void {
		if (domainCounter[domain] != undefined) {
			domainCounter[domain]++;
		}
		else {
			domainCounter[domain] = 1;
		}
		contextMap[context] = domain;
		context.addEventListener(ContextEvent.DESTROYED, contextDestroyed);
	}

	private static function contextDestroyed (event:ContextEvent) : void {
		var context:Context = event.target as Context;
		context.removeEventListener(ContextEvent.DESTROYED, contextDestroyed);
		if (contextMap[context] == undefined) {
			log.warn("No domain cached for Context");
			return;
		}
		var domain:ApplicationDomain = contextMap[context] as ApplicationDomain;
		delete contextMap[context];
		if (domainCounter[domain] == undefined) {
			log.warn("No counter available for ApplicationDomain");
			return;
		}
		if (domainCounter[domain] > 1) {
			domainCounter[domain]--;
		}
		else {
			log.info("Purging reflection cache for ApplicationDomain that is no longer used by any Context");
			delete domainCounter[domain];
			ClassInfo.purgeCache(domain);
		}
	}
	
	
}
}