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
 
package org.spicefactory.parsley.context.binding {
import org.spicefactory.lib.errors.IllegalArgumentError;
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.lib.util.Command;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.localization.LocaleManager;
import org.spicefactory.parsley.localization.events.LocaleSwitchEvent;

/**
 * Binding implementation that supports binding of a property value
 * to localized messages automatically updating when the current locale is switched.
 * 
 * @author Jens Halm
 */
public class MessageBinding implements Binding {
	
	
	private var _context:ApplicationContext;
	private var _key:String;
	private var _bundle:String;
	private var _parameters:Array;
	private var _parameterCommand:Command;
	private var _target:Object;
	private var _property:Property;
	
	
	/**
	 * Creates a new instance.
	 * If the optional bundle name parameter is omitted the default bundle will be used.
	 * 
	 * @param context the context to retrieve localized messages from
	 * @param key the message key
	 * @param bundle the name of the bundle
	 */
	function MessageBinding (context:ApplicationContext, key:String, bundle:String = null) {
		_context = context;
		_key = key;
		_bundle = bundle;		
	}
	
	/**
	 * @inheritDoc
	 */
	public function bind (target:Object, property:String) : void {
		if (_target != null) {
			throw new IllegalStateError("Message is already bound");
		}
		_target = target;
		_property = ClassInfo.forInstance(target).getProperty(property);
		if (_property == null) {
			throw new IllegalArgumentError("Given instance does not have a property with name " + property);
		}
		ApplicationContext.localeManager.addEventListener(LocaleSwitchEvent.COMPLETE, onLocaleSwitch);
		update();
	}
		
	/**
	 * @inheritDoc
	 */
	public function unbind () : void {
		ApplicationContext.localeManager.removeEventListener(LocaleSwitchEvent.COMPLETE, onLocaleSwitch);
	}
	
	/**
	 * The parameter values for a parameterized message.
	 * 
	 * @param value the Array containing the parameters for the message
	 */
	public function set parameters (value:Array) : void {
		_parameters = value;
	}
	
	/**
	 * A <code>Command</code> instance to execute to obtain the message parameters.
	 * The return type of the specified <code>Command</code> must be <code>Array</code>.
	 * 
	 * @param command the Command to retrieve the message parameters from
	 */
	public function set parameterCommand (command:Command) : void {
		_parameterCommand = command;
	}
	
	private function onLocaleSwitch (event : LocaleSwitchEvent) : void {
		update();
	}
	
	/**
	 * Explicitly updates the binding. Only necessary when the parameters for the message have
	 * changed. Switching of the current locale will automatically be detected and update the
	 * binding.
	 */
	public function update () : void {
		var params:Array = 
			(_parameters == null) ? 
				((_parameterCommand == null) ? [] : _parameterCommand.execute() as Array)
				: _parameters;
		_property.setValue(_target, _context.getMessage(_key, _bundle, params));
	}		
		
}

}