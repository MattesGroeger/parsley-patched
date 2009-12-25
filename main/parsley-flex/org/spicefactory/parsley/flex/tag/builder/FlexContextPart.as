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
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.flex.FlexContextBuilder;

/**
 * MXML tag for adding a MXML configuration class to a CompositeContext.
 * 
 * <p>Example:</p>
 * 
 * <pre><code>&lt;parsley:CompositeContext&gt;
 *     &lt;parsley:FlexContextPart config="{BookStoreConfig}"/&gt;
 *     &lt;parsley:XmlContextPart config="logging.xml"/&gt;
 * &lt;/parsley:CompositeContext&gt;</code></pre> 
 * 
 * @author Jens Halm
 */
public class FlexContextPart implements CompositeContextPart {
	
	
	/**
	 * The class that contains the MXML configuration.
	 */
	public var config:Class;
	
	
	/**
	 * @private
	 */
	public function addBuilders (builder:CompositeContextBuilder) : void {
		FlexContextBuilder.merge(config, builder);
	}
	
	
}
}
