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

package org.spicefactory.parsley.flex.tag.builder {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.flex.FlexLogFactory;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.flex.modules.FlexModuleSupport;

[DefaultProperty("parts")]
/**
 * MXML tag for creating a Context that combines multiple configuration mechanisms.
 * The individual configurations can be specified with child tags:
 * 
 * <pre><code>&lt;parsley:CompositeContext&gt;
 *     &lt;parsley:FlexContextPart config="{BookStoreConfig}"/&gt;
 *     &lt;parsley:XmlContextPart config="logging.xml"/&gt;
 * &lt;/parsley:CompositeContext&gt;</code></pre> 
 * 
 * @author Jens Halm
 */
public class CompositeContext extends ContextBuilderTagBase {
	
	
	[ArrayElementType("org.spicefactory.parsley.flex.tag.builder.CompositeContextPart")]
	/**
	 * The individual configuration artifacts for this Context.
	 */
	public var parts:Array;
	
	
	/**
	 * @private
	 */
	protected override function addBuilders (builder:CompositeContextBuilder) : void {
		if (parts == null || parts.length == 0) {
			throw new IllegalStateError("No builders specified for this CompositeContext");
		}
		if (LogContext.factory == null) LogContext.factory = new FlexLogFactory();
		FlexModuleSupport.initialize();
		for each (var part:CompositeContextPart in parts) {
			part.addBuilders(builder);
		}
	}
	
	
}
}
