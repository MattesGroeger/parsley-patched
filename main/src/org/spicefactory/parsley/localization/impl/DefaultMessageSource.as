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
 
package org.spicefactory.parsley.localization.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.task.TaskGroup;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.lib.util.collection.ArrayList;
import org.spicefactory.lib.util.collection.List;
import org.spicefactory.parsley.localization.Locale;
import org.spicefactory.parsley.localization.MessageBundle;
import org.spicefactory.parsley.localization.spi.MessageBundleSpi;
import org.spicefactory.parsley.localization.spi.MessageSourceSpi;

/**
 * Default implementation of the <code>MessageSourceSpi</code> interface.
 * 
 * @author Jens Halm
 */
public class DefaultMessageSource implements MessageSourceSpi {
		
	private var _cacheable:Boolean;
	
	private var _defaultBundle:MessageBundleSpi;
	private var _bundles:Object;
	
	private var _children:List;
	private var _parent:MessageSourceSpi;	
	
	private static var _logger:Logger;
	
	
	/**
	 * Creates a new instance.
	 */
	public function DefaultMessageSource () {
		if (_logger == null) {
			_logger = LogContext.getLogger("org.spicefactory.parsley.localization.DefaultMessageSource");
		}
		_defaultBundle = new DefaultMessageBundle();
		_bundles = new Object();
		_children = new ArrayList();
	}
	
	/**
	 * @inheritDoc
	 */
	public function addChild (ms:MessageSourceSpi) : void {
		_children.append(ms);	
	}
	
	public function set parent (ms:MessageSourceSpi) : void {
		_parent = ms;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get parent () : MessageSourceSpi {
		return _parent;
	}
	
	public function set cacheable (cacheable:Boolean) : void {
		_cacheable = cacheable;
		for each (var bundle:MessageBundle in _bundles) {
			bundle.cacheable = cacheable;
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function get cacheable () : Boolean {
		return _cacheable;
	}
	
	public function set defaultBundle (bundle:MessageBundleSpi) : void {
		addBundle(bundle);
		_defaultBundle = bundle;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get defaultBundle () : MessageBundleSpi {
		return _defaultBundle;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addBundle (bundle:MessageBundleSpi) : void {
		bundle.cacheable = _cacheable;
		_bundles[bundle.id] = bundle;
	}
	
	/**
	 * @inheritDoc
	 */
	public function getBundle (bundleId:String = null) : MessageBundle {
		if (bundleId == null) {
			return _defaultBundle;
		} else {
			return MessageBundle(_bundles[bundleId]);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function getMessage (messageKey:String, bundleId:String = null, params:Array = null) : String {
		params = (params == null) ? new Array() : params ;
		var bundle:MessageBundle = getBundle(bundleId);
		if (bundle == null) {
			return (_parent == null) ? null : _parent.getMessage(messageKey, bundleId, params);
		}
		return bundle.getMessage(messageKey, params);
	}
	
	/**
	 * @inheritDoc
	 */
	public function addBundleLoaders (loc:Locale, chain : TaskGroup) : void {
		for each (var bundle:MessageBundleSpi in _bundles) {
			bundle.addLoaders(loc, chain);
		}
		for (var i:Number = 0; i < _children.getSize(); i++) {
			var ms:MessageSourceSpi = MessageSourceSpi(_children.get(i));
			ms.addBundleLoaders(loc, chain);
		}
		chain.addEventListener(TaskEvent.COMPLETE, onLoad);
	}
	
	private function onLoad (event:TaskEvent) : void {
		for each (var bundle:MessageBundleSpi in _bundles) {
			bundle.applyNewMessages();
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function destroy () : void {
		for each (var bundle:MessageBundleSpi in _bundles) {
			bundle.destroy();
		}
	}
	
		
}
	
}