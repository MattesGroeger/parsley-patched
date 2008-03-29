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
 
package org.spicefactory.parsley.context {
import flash.events.ErrorEvent;
import flash.events.Event;

import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.task.SequentialTaskGroup;
import org.spicefactory.lib.task.Task;
import org.spicefactory.lib.task.TaskGroup;
import org.spicefactory.lib.task.enum.TaskState;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.parsley.context.ns.context_internal;
import org.spicefactory.parsley.context.tree.core.ApplicationContextConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.localization.Locale;
import org.spicefactory.parsley.localization.events.LocaleSwitchEvent;
import org.spicefactory.parsley.localization.spi.LocaleManagerSpi;
import org.spicefactory.parsley.localization.spi.MessageSourceSpi;
import org.spicefactory.parsley.util.XmlLoaderTask;

/**
 * Class responsible for loading and parsing of configuration files.
 * Configuration can be split into multiple XML configuration files. All files added
 * with the <code>addFile</code> method will be processed as if their content was
 * obtained from a single file. You can also add XML instances obtained by some other means
 * with the <code>addXml</code> method. These instance will be treated the same like those
 * loaded from files.
 * 
 * <p>A simple example for loading a single configuration file and then retrieving a Point 
 * instance from the loaded context:</p>
 * 
 * <p>The configuration file:</p>
 * 
 * <code><pre>
 * &lt;application-context 
 *     xmlns="http://www.spicefactory.org/parsley/1.0"
 *     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 *     xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 
 *     http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd"
 *     &gt;
 *     &lt;factory&gt;
 *         &lt;object id="testPoint" type="flash.geom.Point"&gt;
 *             &lt;constructor-args&gt;
 *                 &lt;number&gt;0.5&lt;/number&gt;
 *                 &lt;number&gt;3&lt;/number&gt;
 *             &lt;/constructor-args&gt;
 *         &lt;/object&gt;
 *     &lt;/factory&gt;
 * &lt;/application-context&gt;
 * </pre></code>
 * 
 * <p>The code to load that file:</p>
 * 
 * <code><pre>
 * public function load () : void {
 *     var parser:ApplicationContextParser = new ApplicationContextParser("test");
 *     parser.addFile("config/testContext.xml");
 *     parser.addEventListener(TaskEvent.COMPLETE, onComplete);
 *     parser.addEventListener(TaskEvent.ERROR, onError);
 *     parser.start();
 * }
 * 
 * private function onLoad (event:TaskEvent) : void {
 *     var parser:ApplicationContextParser = ApplicationContextParser(event.target);
 *     var context:ApplicationContext = parser.applicationContext;
 *     var p:Point = Point(context.getObject("testPoint"));
 *     trace("x = " + p.x + " - y = " + p.y);
 * }
 * 
 * private function onError (event:ErrorEvent) : void {
 *     trace("Error loading context: " + event.text);
 * }
 * </pre></code>
 * 
 * @author Jens Halm
 */
public class ApplicationContextParser extends Task {
	
	use namespace context_internal;
	
	private static var _logger:Logger;
	
	private var _name:String;
	private var _useAsRoot:Boolean;
	private var _cacheable:Boolean;
	private var _parentContext:ApplicationContext;
	private var _locale:Locale;
	
	private var _files:Array;
	private var _xml:Array;
	
	private var _loader:XmlLoaderTask;
	
	private var _config:ApplicationContextConfig;
	private var _context:ApplicationContext;
	
	
	private static var _cache : Object;
	private static var _underConstruction:Array = new Array();
	
	/**
	 * Clears the cache, removing all previously loaded <code>ApplicationContext</code>
	 * instances.
	 */
	public static function clearCache () : void { 
		_cache = new Object();
	}
	
	/**
	 * @private
	 */
	internal static function removeFromCache (context:ApplicationContext) : void {
		delete _cache[context.name];
	}
	
	/**
	 * Creates a new instance. The name parameter serves as an identifier. If you set
	 * the <code>cacheable</code> property of an <code>ApplicationContextParser</code> 
	 * to <code>true</code>, the next time you try to load a context with the same name
	 * you will get the already loaded instance. Furthermore the context is accessible by
	 * name with the static <code>ApplicationContext.forName(name:String)</code> method.
	 * If you specify <code>true</code> for the optional <code>useAsRoot</code> parameter
	 * the context is also accessible with the static <code>ApplicationContext.root()</code>
	 * method.
	 * 
	 * @param name the name that should be assigned to the loaded <code>ApplicationContext</code>
	 * @param useAsRoot whether the loaded <code>ApplicationContext</code> should be used as the root context
	 */
	public function ApplicationContextParser (name:String, useAsRoot:Boolean = false) {
		if (_logger == null) {
			_logger = LogContext.getLogger("org.spicefactory.parsley.context.ApplicationContextParser");
		}
		if (_cache == null) {
			_cache = new Object();
		}
		_name = name;
		_useAsRoot = useAsRoot;
		_cacheable = false;
		_files = new Array();
		_xml = new Array();
		setRestartable(false);
		setSuspendable(false);
		setSkippable(false);
		setCancelable(true);
	}
	
	/**
	 * @copy org.spicefactory.parsley.context.ApplicationContext#config
	 */
	public function get config () : ApplicationContextConfig {
		return _config;
	}
	
	/**
	 * The parent <code>ApplicationContext</code>.
	 * If this property is set, objects configured in this context can reference objects
	 * from the parent context (but not vice versa).
	 */
	public function get parentContext () : ApplicationContext {
		return _parentContext;
	}
	public function set parentContext (parent:ApplicationContext) : void {
		_parentContext = parent;
	}
	
	/**
	 * The initial <code>Locale</code> to use when processing the <code>ApplicationContext</code>.
	 */
	public function get locale () : Locale {
		// TODO - 1.0.1 - doc other means the locale can be determined
		return _locale;
	}
	public function set locale (loc:Locale) : void {
		_locale = loc;
	}
	
	/**
	 * This property is deprecated, it will be removed in version 1.1.0. 
	 * Use <code>ApplicationContext.forName</code> or <code>ApplicationContext.root</code>
	 * to access already loaded context instances.
	 * 
	 * <p>Indicates whether this context can be cached.
	 * If this property is set to true, and an <code>ApplicationContext</code> with the same name
	 * has already been loaded, this parser will use the cached
	 * context instance and immediately fire the <code>COMPLETE</code> event.
	 * This may be useful if many modules have to load the same <code>ApplicationContext</code>
	 * but it is not known until runtime which module will be the first.</p>
	 */
	public function get cacheable () : Boolean {
		return _cacheable;
	}
	public function set cacheable (cacheable : Boolean) : void {
		_cacheable = cacheable;
	}
	
	/**
	 * Adds the configuration file with the specified name to the list of files to be processed.
	 * 
	 * @param filename the name of the file to be loaded
	 */
	public function addFile (filename:String) : void {
		// TODO - 1.0.1 - check state
		_files.push(filename);
	}
	
	/**
	 * Adds an XML instance to the list of XML objects to be processed.
	 * The format of this XML object should be the same like that for external files
	 * loaded with this parser.
	 * 
	 * @param xml the XML object to add to the list of XML objects to be processed
	 */
	public function addXml (xml:XML) : void {
		// TODO - 1.0.1 - check state
		_xml.push(xml);
	}
	
	/**
	 * @private
	 */
	context_internal static function getContextsUnderConstruction () : Array {
		return _underConstruction.concat();
	} 

	// TODO - 1.1.0 - addObjectFactory + addObject
	/**
	 * @private
	 */
	protected override function doStart () : void {
		if (_cacheable && _cache[_name] != undefined) {
			_logger.info("Take existing context with name " + _name + " from cache");
			_context = ApplicationContext(_cache[_name]);
			complete();
			return;
		}
		if (_parentContext == null && ApplicationContext.root != null) {
			_parentContext = ApplicationContext.root;
		}
		_config = new ApplicationContextConfig();
		_context = new ApplicationContext(_name, _config, _parentContext);
		_config.context = _context;
		_underConstruction.push(_context);
		
		try {
			for each (var node:XML in _xml) {
				parse(node);
			}
		} catch (e:Error) {
			handleParserError(e);
			return;
		}
		loadNextFile();
	}
	
	
	private function loadNextFile () : void {
		if (_files.length == 0) {
			process();
			return;
		}
		_logger.debug("Start loading next file: " + _files[0]);
		_loader = new XmlLoaderTask(String(_files.shift()));
		_loader.addEventListener(TaskEvent.COMPLETE, onLoad);
		_loader.addEventListener(ErrorEvent.ERROR, handleTaskError);
		_loader.start();
	}
	
	private function onLoad (event:TaskEvent) : void {
		var loader : XmlLoaderTask = XmlLoaderTask(event.target);
		if (state != TaskState.ACTIVE) return;
		try {
			parse(loader.xml);
		} catch (e:Error) {
			handleParserError(e);
			return;
		}
		loadNextFile();
	}
	
	private function parse (node:XML) : void {
		var qname:QName = node.name() as QName;
		if (qname.uri != DefaultElementProcessor.PARSLEY_NAMESPACE_URI) {
			throw new ConfigurationError("Root node is not in Namespace " + DefaultElementProcessor.PARSLEY_NAMESPACE_URI);
		} else if (qname.localName != "application-context") {
			throw new ConfigurationError("Root node is not <application-context>");
		}
		_config.parse(node, _context);
		_config.setupConfig.includesConfig.process(this);
	}
	
	private function process () : void {
		try {
			_config.setupConfig.process();
		} catch (e:Error) {
			handleParserError(e);
			return;
		}			
		loadMessages();
	}
	

	private function loadMessages () : void {
		_context.initLocaleManager();
		var ms:MessageSourceSpi = MessageSourceSpi(_context.messageSource);
		var lm:LocaleManagerSpi = LocaleManagerSpi(ApplicationContext.localeManager);
		if (_parentContext != null) {
			var queue : TaskGroup = new SequentialTaskGroup("TaskQueue for loading MessageSources into ApplicationContextParser");
			queue.addEventListener(ErrorEvent.ERROR, handleTaskError);
			queue.addEventListener(TaskEvent.COMPLETE, processRemaining);
			ms.addBundleLoaders(lm.currentLocale, queue);
			queue.start();
		} else {
			lm.addEventListener(ErrorEvent.ERROR, handleTaskError);
			lm.addEventListener(LocaleSwitchEvent.COMPLETE, processRemaining);
			lm.initialize(_locale);
		}
	}
	
	
	
	private function reset () : void {
		ApplicationContext.localeManager.removeEventListener(ErrorEvent.ERROR, handleTaskError);
		ApplicationContext.localeManager.removeEventListener(LocaleSwitchEvent.COMPLETE, processRemaining);
	}
	
	/*
	 * Event argument may be LocaleSwitchEvent or TaskEvent
	 */
	private function processRemaining (event:Event) : void {
		reset();
		try {
			_config.factoryConfig.process();
		} catch (e:Error) {
			handleParserError(e);
			return;
		}	
		if (_cacheable) {
			_cache[_name] = _context;
		}
		ArrayUtil.remove(_underConstruction, _context);
		_context.initialize(_useAsRoot);
		complete();
	}
	
	private function handleTaskError (evt:ErrorEvent) : void {
		handleParserErrorMessage(evt.text);
		reset();
	}
	
	private function handleParserError (e:Error) : void {
		_logger.error("Error parsing ApplicationContext", e);
		handleParserErrorMessage(e.message);
	}
	
	private function handleParserErrorMessage (msg:String) : void {
		_context = null;
		_logger.error(msg);
		error(msg);
	}	
	
	/**
	 * The <code>ApplicationContext</code> instance loaded and parsed by this parser.
	 * Will be null until the context is fully loaded, parsed and initialized.
	 */
	public function get applicationContext () : ApplicationContext {
		if (_context == null) {
			throw new ConfigurationError("Parsing was not completed yet, was canceled or never started " + 
					"or context contained errors");
		}
		return _context;
	}
	
	/**
	 * @private
	 */
	public override function toString () : String {
		return "[ApplicationContextParser name = " + _name + "]";
	}
	
	
	
}

}