/*
* Copyright 2008-2010 the original author or authors.
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
package org.spicefactory.parsley.sample.helloworld
{
	/**
	 * A simple message class with just one string property. Any kind of object 
	 * can be sent as a message using a Parsley Message Dispatcher. 
	 * 
	 * Parsley also allows events to be sent as messages via the standard 
	 * EventDispatcher and accompanying [ManagedEvents] metadata. Refer to the
	 * chapter about the Messaging Framework in the Developer Manual for more 
	 * details.
	 * 
	 * @author Tom Sugden
	 */
	public class HelloWorldMessage
	{
		public var text:String = "Hello World!";
	}
}