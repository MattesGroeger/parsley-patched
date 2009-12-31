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

package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.parsley.tag.lifecycle.AbstractSynchronizedProviderDecorator;

/**
 * Abstract base class for decorators used for message receivers that offer the attributes type, selector and order.
 * 
 * <p>It is recommended that subclasses simply override the (pseudo-)abstract methods
 * <code>handleProvider</code> and (optionally) <code>validate</code> instead of implementing
 * the <code>decorate</code> method itself, since this base class already does some
 * of the plumbing.</p>
 * 
 * @author Jens Halm
 */
public class AbstractMessageReceiverDecorator extends AbstractSynchronizedProviderDecorator {
	

	/**
	 * The type of the messages the receiver wants to handle.
	 */
	public var type:Class;

	/**
	 * An optional selector value to be used in addition to selecting messages by type.
	 * Will be checked against the value of the property in the message marked with <code>[Selector]</code>
	 * or against the event type if the message is an event and does not have a selector property specified explicitly.
	 */
	public var selector:*;
	
	/**
	 * The execution order for this receiver. Will be processed in ascending order. 
	 * The default is <code>int.MAX_VALUE</code>.</p>
	 */
	public var order:int = int.MAX_VALUE;
	
	
}
}
