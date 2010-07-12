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

package org.spicefactory.parsley.core.factory.impl {
import org.spicefactory.parsley.core.view.impl.DefaultViewAutowireFilter;
import org.spicefactory.lib.util.Flag;
import org.spicefactory.parsley.core.view.ViewAutowireFilter;
import org.spicefactory.parsley.core.factory.ViewSettings;

/**
 * Default implementation of the ViewSettings interface.
 * 
 * @author Jens Halm
 */
public class DefaultViewSettings implements ViewSettings {


	private var _parent:ViewSettings;
	
	private var _autoremoveViewRoots:Flag;
	private var _autoremoveComponents:Flag;
	private var _autowireComponents:Flag;
	private var _autowireFilter:ViewAutowireFilter;

	
	public function set parent (parent:ViewSettings) : void {
		_parent = parent;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function get autoremoveViewRoots () : Boolean {
		return (_autoremoveViewRoots) 
				? _autoremoveViewRoots.value 
				: ((_parent) ? _parent.autoremoveViewRoots : true);
	}

	/**
	 * @inheritDoc
	 */
	public function set autoremoveViewRoots (value:Boolean) : void {
		_autoremoveViewRoots = new Flag(value);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get autoremoveComponents () : Boolean {
		return (_autoremoveComponents) 
				? _autoremoveComponents.value 
				: ((_parent) ? _parent.autoremoveComponents : true);
	}
	
	/**
	 * @inheritDoc
	 */
	public function set autoremoveComponents (value:Boolean) : void {
		_autoremoveViewRoots = new Flag(value);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get autowireComponents () : Boolean {
		return (_autowireComponents) 
				? _autowireComponents.value 
				: ((_parent) ? _parent.autowireComponents : false);
	}
	
	/**
	 * @inheritDoc
	 */
	public function set autowireComponents (value:Boolean) : void {
		_autoremoveViewRoots = new Flag(value);
	}
	
	/**
	 * @inheritDoc
	 */
	public function get autowireFilter () : ViewAutowireFilter {
		return (_autowireFilter) 
				? _autowireFilter 
				: ((_parent) ? _parent.autowireFilter : new DefaultViewAutowireFilter(this));
	}
	
	/**
	 * @inheritDoc
	 */
	public function set autowireFilter (value:ViewAutowireFilter) : void {
		_autowireFilter = value;
	}
	
	
}
}
