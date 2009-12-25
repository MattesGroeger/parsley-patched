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
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.flex.FlexLogFactory;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.flex.modules.FlexModuleSupport;
import org.spicefactory.parsley.xml.XmlContextBuilder;

/**
 * MXML tag for creating a Context from a single XML configuration file.
 * 
 * <p>Example:</p>
 * 
 * <pre><code>&lt;parsley:XmlContext config="bookStoreConfig.xml"/&gt;</code></pre> 
 * 
 * @author Jens Halm
 */
public class XmlContext extends ContextBuilderTagBase {
	
	
	/**
	 * The name of the file that contains the XML configuration.
	 */
	public var file:String;
	
	
	/**
	 * @private
	 */
	protected override function addBuilders (builder:CompositeContextBuilder) : void {
		if (LogContext.factory == null) LogContext.factory = new FlexLogFactory();
		FlexModuleSupport.initialize();
		XmlContextBuilder.merge(file, builder);
	}
	
	
}
}
