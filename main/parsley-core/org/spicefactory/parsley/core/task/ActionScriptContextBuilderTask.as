/*
 * Copyright 2008-2009 the original author or authors.
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
import org.spicefactory.parsley.core.Context;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class ActionScriptContextBuilderTask {
	
	
	
	public static function build (container:Class, parent:Context = null, domain:ApplicationDomain = null) : ContextBuilderTask {
		return buildAll([container], parent, domain);		
	}
	
	public static function buildAll (containers:Array, parent:Context = null, domain:ApplicationDomain = null) : ContextBuilderTask {
		return new ContextBuilderTaskImpl(containers, parent, domain);		
	}
	
	
	public static function merge (container:Class, builder:CompositeContextBuilderTask) : void {
		mergeAll([container], builder);
	}
	
	public static function mergeAll (containers:Array, builder:CompositeContextBuilderTask) : void {
		builder.addBuilderTask(new MergeTaskImpl(containers, builder));
	}
	
	
}
}

import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.impl.ActionScriptObjectDefinitionBuilder;

import flash.system.ApplicationDomain;

class ContextBuilderTaskImpl extends ContextBuilderTask {
	
	private var containers:Array;
	
	function ContextBuilderTaskImpl (containers:Array, parent:Context, domain:ApplicationDomain) {
		super(parent, domain);
		this.containers = containers;
	}
	
	protected override function build (parent:Context = null, domain:ApplicationDomain = null) : Context {
		return ActionScriptContextBuilder.buildAll(containers, parent, domain);
	}
}

class MergeTaskImpl extends Task {
	
	private static var defBuilder:ActionScriptObjectDefinitionBuilder = new ActionScriptObjectDefinitionBuilder();
	
	private var containers:Array;
	private var compositeBuilder:CompositeContextBuilderTask;
	
	function MergeTaskImpl (containers:Array, compositeBuilder:CompositeContextBuilderTask) {
		this.containers = containers;
		this.compositeBuilder = compositeBuilder;
	}
	
	protected override function doStart () : void {
		// this is a fully snychronous Task
		defBuilder.build(containers, compositeBuilder.registry);
		complete();
	}
	
}
