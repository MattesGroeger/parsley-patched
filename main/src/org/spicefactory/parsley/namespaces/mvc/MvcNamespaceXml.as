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
 
package org.spicefactory.parsley.namespaces.mvc {

/**
 * Static constant for the configuration XML that needs to be included
 * with an <code>ApplicationContextParser</code> when using the custom configuration
 * namespace of the MVC Framework.
 * 
 * @author Jens Halm
 */
public class MvcNamespaceXml {
	
	
	/**
	 * The configuration XML that needs to be included
 	 * with an <code>ApplicationContextParser</code> when using the custom configuration
 	 * namespace of the MVC Framework
	 */
	public static function get config () : XML {
		var c:Class = ActionConfigProcessor;
		c = EventSourceConfigProcessor;
		c = InterceptorConfigProcessor;
		return <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
		<setup>
			<namespaces>
				<namespace uri="http://www.spicefactory.org/parsley/1.0/mvc">
					<processor-config tag-name="action" type="org.spicefactory.parsley.namespaces.mvc.ActionConfigProcessor"/>
					<processor-config tag-name="interceptor" type="org.spicefactory.parsley.namespaces.mvc.InterceptorConfigProcessor"/>
					<processor-config tag-name="event-source" type="org.spicefactory.parsley.namespaces.mvc.EventSourceConfigProcessor"/>
				</namespace>
			</namespaces>
		</setup>
		</application-context>;
	}
	
	
}

}
