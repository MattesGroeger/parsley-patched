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

package org.spicefactory.parsley.core.messaging.impl {
import org.spicefactory.parsley.core.messaging.receiver.MessageReceiver;

import flash.utils.Dictionary;

/**
 * @author Jens Halm
 */
public class MessageReceiverCollection {
	
	
	private var receiversWithSelector:Array = new Array();
	private var receiversWithoutSelector:Array = new Array();
	private var selectorMap:Dictionary = new Dictionary();
	
	
	function MessageReceiverCollection () {
		
	}
	
	/**
	 * Adds a message receiver to this selection.
	 * 
	 * @param receiver the receiver to add
	 */
	public function addReceiver (receiver:MessageReceiver) : void {
		if (receiver.selector == undefined) {
			receiversWithoutSelector.push(receiver);
		}
		else {
			receiversWithSelector[receiver.selector] = receiver;
		}
	}
	
	public function getReceicers (selectorValue:*) : Array {
		var receivers:Array = null;
		if (selectorMap[selectorValue] != undefined) {
			receivers = selectorMap[selectorValue];
		}
		else {
			receivers = new Array();
			selectorMap[selectorValue] = receivers;
			for each (var target:MessageReceiver in receiversWithSelector) {
				if (target.selector == selectorValue) {
					receivers.push(target);
				}
			}
		}
		return receivers.concat(receiversWithoutSelector);
	}
	
	
}
}
