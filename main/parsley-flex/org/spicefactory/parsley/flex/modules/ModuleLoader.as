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

package org.spicefactory.parsley.flex.modules {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.Context;

import mx.modules.ModuleLoader;

import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

/**
 * @author Jens Halm
 */
public class ModuleLoader extends mx.modules.ModuleLoader {
	
	
	private static const log:Logger = LogContext.getLogger(ModuleLoader);

	public var parentContext:Context;
	
	private var builder:Builder;
	
	
	public override function loadModule (url:String = null, bytes:ByteArray = null) : void {
		url = (url != null) ? url : this.url;
		if (url == null) {
			return;
		}
		if (parentContext == null) {
			log.warn("Parent context not specified for module with URL " + url);
		}
		// must explicitly create domain instance here, we would not have access to it afterwards
		if (applicationDomain == null) {
			applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		}
		builder = new Builder(this);
		ModuleManager.getInstance().registerModule(url, parentContext, applicationDomain, builder);
		super.loadModule(url, bytes);
	}
}
}

import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.Context;

import mx.modules.ModuleLoader;

import flash.display.DisplayObject;
import flash.system.ApplicationDomain;

class Builder implements ModuleContextBuilder {


	private static const log:Logger = LogContext.getLogger(ModuleContextBuilder);
	private var loader:ModuleLoader;

	
	function Builder (loader:ModuleLoader) {
		this.loader = loader;
	}
	
	
	public function build (parent:Context, domain:ApplicationDomain) : Context {
		var child:DisplayObject = loader.child;
		if (child == null) {
			log.warn("No child has been created for ModuleLoader with URL " + loader.url);
			return null;
		}
		if (!(child is Module)) {
			log.warn("Child created for ModuleLoader with URL " + loader.url + " does not extend the Parsley Module class");
			return null;
		}
		return Module(child).buildContext(parent, domain);
	}
	
}
