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

package org.spicefactory.parsley.flex.tag.builder {
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.factory.ViewSettings;
import org.spicefactory.parsley.core.factory.impl.DefaultViewSettings;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;

/**
 * MXML tag for providing the settings to apply for dynamic view wiring. 
 * The tag can be used as a child tag of the ContextBuilder tag:</p>
 * 
 * <pre><code>&lt;parsley:ContextBuilder&gt;
 *     &lt;parsley:ViewSettings autoremoveComponents="false" autowireComponents="true"/&gt;
 *     &lt;parsley:FlexConfig type="{BookStoreConfig}"/&gt;
 *     &lt;parsley:XmlConfig file="logging.xml"/&gt;
 * &lt;/parsley:CompositeContext&gt;</code></pre> 
 * 
 * @author Jens Halm
 */

public class ViewSettingsTag extends DefaultViewSettings implements ContextBuilderProcessor {
	
	/**
	 * Indicates whether the settings in this tag should only applied
	 * to the Context built by the corresponding ContextBuilder tag.
	 * If set to false (the default) these settings will be applied globally,
	 * but not to Context instances that were already built.
	 */
	public var local:Boolean = false;
	
	/**
	 * @private
	 */
	public function processBuilder (builder:CompositeContextBuilder) : void {
		var settings:ViewSettings = (local) ? builder.factories.viewSettings : GlobalFactoryRegistry.instance.viewSettings;
		settings.autoremoveComponents = autoremoveComponents;
		settings.autoremoveViewRoots = autoremoveViewRoots;
		settings.autowireComponents = autowireComponents;
		if (autowireFilter) {
			settings.autowireFilter = autowireFilter;
		}
	}
	
	
}
}
