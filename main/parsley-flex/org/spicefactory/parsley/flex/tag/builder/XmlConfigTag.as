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
import org.spicefactory.parsley.xml.processor.XmlConfigurationProcessor;

/**
 * MXML tag for adding an XML configuration file to a ContextBuilder.
 * 
 * <p>Example:</p>
 * 
 * <pre><code>&lt;parsley:ContextBuilder&gt;
 *     &lt;parsley:FlexConfig type="{BookStoreConfig}"/&gt;
 *     &lt;parsley:XmlConfig file="logging.xml"/&gt;
 * &lt;/parsley:ContextBuilder&gt;</code></pre> 
 * 
 * @author Jens Halm
 */
public class XmlConfigTag implements ContextBuilderProcessor {
	
	
	/**
	 * The name of the file that contains the XML configuration.
	 */
	public var file:String;
	
	
	/**
	 * @private
	 */
	public function process (builder:CompositeContextBuilder) : void {
		builder.addProcessor(new XmlConfigurationProcessor([file]));
	}
	
	
}
}
