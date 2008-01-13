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
 
package org.spicefactory.parsley.mvc {

/**
 * Intercepts an event before the actual actions registered for that event are executed.
 * The implementation of this interface may interrupt the event flow and resume later
 * or even stop event processing altogether. In case the implementation wants the
 * framework to proceed with event processing it should invoke <code>ActionProcessor.proceed</code>.
 * 
 * <p>A simple example that opens a Flex Alert and only proceeds if the user clicks ok:</p>
 * 
 * <code>
 * package example {
 * 
 * public class DeleteItemInterceptor implements ActionInterceptor {
 * 
 *     public function intercept (processor:ActionProcessor) : void {
 *         var listener:CloseEventListener = new CloseEventListener(processor);
 *         Alert.show("Do you really want to delete this item?", "Warning", 
 *             Alert.OK | Alert.CANCEL, null, listener.handleCloseEvent);
 *     }
 * 
 * }
 * 
 * }
 * 
 * class CloseEventListener {
 * 
 *     private var processor:ActionProcessor
 * 
 *     function CloseEventListener (processor:ActionProcessor) {
 *         this.processor = processor
 *     }
 * 
 *     public function handleCloseEvent (event:CloseEvent) : void {
 *         if (event.detail = Alert.OK) {
 *             processor.proceed();
 *         }
 *     }
 * 
 * } 
 * </code>
 * 
 * <p>Note that for anything that needs to keep internal state you have to create a separate
 * instance like in the example above the <code>CloseEventListener</code>. This is because
 * the interceptor instance itself is reused for multiple actions and thus should be stateless.</p>
 * 
 * @author Jens Halm
 */	
public interface ActionInterceptor {
	
	/**
	 * Intercepts event processing before the actual event listeners registered for that 
	 * event are executed. To resume with event processing <code>ActionProcessor.proceed</code>
	 * must be invoked.
	 * 
	 * @param processor the ActionProcessor that handles the current event
	 */
	function intercept (processor:ActionProcessor) : void;
		
}

}