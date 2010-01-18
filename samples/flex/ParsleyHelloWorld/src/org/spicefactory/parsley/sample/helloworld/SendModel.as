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
	 * This model is declared inside the MXML HelloWorldConfig file. It is then
	 * injected into the SendPanel view component.
	 * 
	 * @author Tom Sugden
	 */
	public class SendModel
	{
		[Bindable]
		public var initialized:Boolean;
		
		/** 
		 * The [Inject] metadata tells Parsley to inject a dependency by 
		 * searching the context for an object of matching type.
		 */
		[Inject]
		[Bindable]
		public var sharedModel:SharedModel;

		/**
		 * The [MessageDispatcher] metadata tells Parsley to configure the 
		 * function so it can be used to send (dispatch) messages.
		 */ 
		[MessageDispatcher]
		public var sendMessage:Function;
		
		/**
		 * The [Init] metadata tells Parsley to call the annotated method after 
		 * an instance of this object is created and configured.
		 */ 
		[Init]
		public function init() : void {
			initialized = true;
		}
		
		/**
		 * This method sends a message via the Parsley messaging framework. 
		 * Any kind of object can be sent as a message by passing it to a 
		 * message dispatcher function.
		 */
		public function sayHello() : void {
			sendMessage(new HelloWorldMessage());
		}
	}
}