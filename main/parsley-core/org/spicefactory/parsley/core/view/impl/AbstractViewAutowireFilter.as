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

package org.spicefactory.parsley.core.view.impl {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.core.view.ViewAutowireFilter;
import org.spicefactory.parsley.core.view.ViewAutowireMode;

import flash.display.DisplayObject;
import flash.events.Event;

/**
 * Abstract base implementation of the ViewAutowireFilter.
 * Subclasses must implement the <code>prefilter</code> and <code>filter</code> methods.
 * 
 * @author Jens Halm
 */
public class AbstractViewAutowireFilter implements ViewAutowireFilter {
	
	
	private var _enabled:Boolean = true;
	private var _eventType:String = Event.ADDED_TO_STAGE;

	
	/**
	 * @inheritDoc
	 */
	public function get enabled () : Boolean {
		return _enabled;
	}
	
	public function set enabled (value:Boolean) : void {
		_enabled = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get eventType () : String {
		return _eventType;
	}
	
	public function set eventType (value:String) : void {
		_eventType = value;
	}

	/**
	 * @inheritDoc
	 */
	public function prefilter (object:DisplayObject) : Boolean {
		throw new AbstractMethodError();
	}
	
	/**
	 * @inheritDoc
	 */
	public function filter (object:DisplayObject) : ViewAutowireMode {
		throw new AbstractMethodError();
	}
	

}
}
