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

package org.spicefactory.lib.reflect.cache {
import org.spicefactory.lib.reflect.ClassInfo;

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

/**
 * Default implementation of the ReflectionCache interface.
 * 
 * @author Jens Halm
 */
public class DefaultReflectionCache implements ReflectionCache {

	
	private var cache:Dictionary = new Dictionary();
	
	private var _active:Boolean = true;
	
	
	private function getDomain (domain:ApplicationDomain) : ApplicationDomain {
		return (domain == null) ? ClassInfo.currentDomain : domain;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addClass (type:ClassInfo, domain:ApplicationDomain = null) : void {
		if (!active) return;
		domain = getDomain(domain);
		var domainCache:Dictionary = cache[domain];
		if (domainCache == null) {
			domainCache = new Dictionary();
			cache[domain] = domainCache;
		}
		domainCache[type.getClass()] = type;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getClass (type:Class, domain:ApplicationDomain = null) : ClassInfo {
		domain = getDomain(domain);
		var domainCache:Dictionary = cache[domain];
		return (domainCache == null) ? null : domainCache[type] as ClassInfo;
	}
	
	/**
	 * @inheritDoc
	 */
	public function purgeClass (type:Class, domain:ApplicationDomain = null) : void {
		domain = getDomain(domain);
		var domainCache:Dictionary = cache[domain];
		if (domainCache == null) {
			return;
		}
		delete domainCache[type];
	}
	
	/**
	 * @inheritDoc
	 */
	public function purgeDomain (domain:ApplicationDomain) : void {
		delete cache[domain];
	}
	
	/**
	 * @inheritDoc
	 */
	public function purgeAll () : void {
		cache = new Dictionary();	
	}
	
	/**
	 * @inheritDoc
	 */
	public function get active () : Boolean {
		return _active;
	}
	
	/**
	 * @inheritDoc
	 */
	public function set active (value:Boolean) : void {
		_active = value;
	}
	
	
}
}
