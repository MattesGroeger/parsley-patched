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
	
import org.spicefactory.parsley.localization.Locale;
import org.spicefactory.parsley.localization.LocaleManager;
	
/**	
 * Service provider interface that extends the public <code>LocaleManager</code> interface.
 * 
 * @author Jens Halm
 */
public interface LocaleManagerSpi extends LocaleManager {
	
	/**
	 * Initializes the <code>LocaleManager</code>. Will be called once at application startup when
	 * the first Parsley <code>ApplicationContext</code> is initialized.
	 * 
	 * @param loc the initial <code>Locale</code> to use.
	 */	
	function initialize (loc:Locale = null) : void ;
		
}
	
}