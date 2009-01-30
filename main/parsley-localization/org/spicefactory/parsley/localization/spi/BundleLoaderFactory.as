/*
 * Copyright 2007-2008 the original author or authors.
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
 
package org.spicefactory.parsley.localization.spi {
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.localization.Locale;		

/**
 * Factory that creates <code>Task</code> instances responsible for loading localized
 * messages.
 * 
 * @author Jens Halm
 */
public interface BundleLoaderFactory {
		
	/**
	 * Creates a <code>Task</code> instance responsible for loading messages
	 * for the specified <code>Locale</code>. The basename parameter may be
	 * ignored by some implementations.
	 * 
	 * @param bundle the message bundle to load messages into
	 * @param loc the Locale to add messages for
	 * @param basename the basename of files containing localized messages for that bundle
	 */
	function createLoaderTask (bundle:ResourceBundleSpi, loc:Locale, basename:String) : Task;		
		
}
	
}