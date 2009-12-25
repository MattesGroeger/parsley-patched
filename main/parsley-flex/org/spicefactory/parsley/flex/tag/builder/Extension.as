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

/**
 * Interface to be implemented by MXML tags that want to initialize extensions before
 * the Context gets built.
 * 
 * <p>The tag can then be used for the <code>extensions</code> Array property of any 
 * MXML ContextBuilder tag:</p>
 * <pre><code>&lt;parsley:CompositeContext&gt;
 *     &lt;parsley:FlexContextPart config="{BookStoreConfig}"/&gt;
 *     &lt;parsley:XmlContextPart config="logging.xml"/&gt;
 *     &lt;parsley:extensions&gt;
 *         &lt;mycustomNS:MyExtension/&gt;
 *     &lt;/parsley:extensions&gt;
 * &lt;/parsley:CompositeContext&gt;</code></pre> 
 * 
 * @author Jens Halm
 */
public interface Extension {
	
	/**
	 * Initializes this extension. Will be invoked before the Context gets created,
	 * so that any extenstions like custom configuration tags or replacements for 
	 * IOC Kernel Services can be installed first. The specified builder instance can
	 * be used to install extensions for one Context only. To initialize a global
	 * extension services like the <code>GlobalFactoryRegistry</code> should be used
	 * and the parameter can simply be ignored.
	 * 
	 * @param builder the builder that will be used to create the Context
	 */
	function initialize (builder:CompositeContextBuilder) : void;
	
}
}
