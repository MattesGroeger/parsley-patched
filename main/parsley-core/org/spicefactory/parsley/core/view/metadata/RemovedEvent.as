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
 
package org.spicefactory.parsley.core.view.metadata {

[Metadata(name="RemovedEvent", types="class", multiple="false")]
/**
 * Represents a metadata tag that can be used to specify the event that initiates
 * the removal from the Context for an individual component.
 * If it is not specified explicitly the default is the event type specified
 * in <code>ViewManagerFactory.componentRemovedEvent</code> in the corresponding Context,
 * which in turn defaults to <code>Event.REMOVED_FROM_STAGE</code>.
 * 
 * @author Jens Halm
 */
public class RemovedEvent {
	
	
	[DefaultProperty]
	/**
	 * The name of the event that signals that the component should be removed
	 * from the Context.
	 */
	public var name:String;
	
	
}
}
