package org.spicefactory.parsley.config {

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.utils.getQualifiedClassName;

import flexunit.framework.TestCase;
import flexunit.framework.TestSuite;

import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.test.localization.LocalizationTest;
import org.spicefactory.parsley.test.mvc.MvcTest;
import org.spicefactory.parsley.test.namespaces.CinnamonTagsTest;
import org.spicefactory.parsley.test.namespaces.LoggingTagsTest;
import org.spicefactory.parsley.test.namespaces.TemplateTest;

public class ApplicationContextParserTest extends TestCase {
	
	
	private var _parser:ApplicationContextParser;
	private var _parserError:String;
	private var _context:ApplicationContext;
	
	// TODO - remove all these:
	protected var _complete:Boolean;
	private var _error:Boolean;	
	private var _callback:Function;
	private var _singleObject:Object;
	private var _expectedType:Class;
	private var _callbackError:Error;
	
	
	
	public function ApplicationContextParserTest (methodName : String = null) {
        super(methodName);
    }
            
    public static function suite () : TestSuite {
        var suite:TestSuite = new TestSuite();
        suite.addTestSuite(EmptyContextTest);
        suite.addTestSuite(ObjectFactoryTest);
        suite.addTestSuite(SetupTest);
        suite.addTestSuite(ApplicationContextTest);
        suite.addTestSuite(ConfigValuesTest);
        suite.addTestSuite(TemplateTest);
        suite.addTestSuite(LoggingTagsTest);
        suite.addTestSuite(CinnamonTagsTest);
        suite.addTestSuite(MvcTest);
        suite.addTestSuite(LocalizationTest);
        return suite;
    }
    
    
    protected function parseForContext (name:String, xml:XML, callback:Function) : void {
    	_callback = callback;
    	startParser(name, xml, onParseForContext, onUnexpectedContextError);
    	checkErrors();
    }
    
    protected function parseForSingleObject (name:String, xml:XML, callback:Function, expectedType:Class) : void {
    	_callback = callback;
    	_expectedType = expectedType;
    	startParser(name, xml, onParseForSingleObject, onUnexpectedContextError);
    	checkErrors();
    }
    
    protected function checkErrors () : void {
    	if (_callbackError != null) {
    		var e1:Error = _callbackError;
    		_callbackError = null;
    		throw e1;
    	} else if (_parserError != null) {
    		var e2:String = _parserError;
    		_parserError = null;
    		fail(e2);  		
    	} else if (!_complete) {
    		fail("Missing complete event");
    	}
    }
    
    private function onParseForContext (event:Event) : void {
    	try {
	    	var parser:ApplicationContextParser = event.target as ApplicationContextParser;
	    	var context:ApplicationContext = parser.applicationContext;
	    	assertNotNull("Expecting context instance", context);
	    	_callback(context);
	    	_complete = true;
	    } catch (e:Error) {
	    	_callbackError = e;
	    }
    }
    
    private function onParseForSingleObject (event:Event) : void {
    	try {
	    	var parser:ApplicationContextParser = event.target as ApplicationContextParser;
	    	var context:ApplicationContext = parser.applicationContext;
	    	assertNotNull("Expecting context instance", context);
	    	assertEquals("Expecting 1 object in context", 1, context.objectCount);
	    	var obj:Object = context.getObject(context.name);
	    	assertNotNull("Expecting Object instance", obj);
	    	if (!(obj is _expectedType)) {
	    		fail("Expected instance of type " + getQualifiedClassName(_expectedType));
	    	} 
	    	_callback(obj);
	    	_complete = true;
	    } catch (e:Error) {
	    	_callbackError = e;
	    }
    }
    
    protected function startParser (name:String, xml:XML, complete:Function,
    		error:Function, asRoot:Boolean = false, cacheable:Boolean = false,
    		parent:ApplicationContext = null, prepare:Function = null) : void {
    	_complete = false;
    	_error = false;
    	var parser:ApplicationContextParser = new ApplicationContextParser(name, asRoot);
    	if (cacheable) {
    		parser.cacheable = true;
    	}
    	if (parent != null) {
    		parser.parentContext = parent;
    	}
    	if (xml != null) {
    		parser.addXml(xml);
    	}
    	if (prepare != null) {
    		prepare(parser);
    	}
    	parser.addEventListener(TaskEvent.COMPLETE, complete);
    	parser.addEventListener(ErrorEvent.ERROR, error);
    	parser.start();
    }
    
	protected function parseForContext2 (name:String, xml:XML, 
			asRoot:Boolean = false, cacheable:Boolean = false, 
			parent:ApplicationContext = null, prepare:Function = null) : ApplicationContext {
    	_parser = null;
    	_context = null;
    	startParser(name, xml, onContextComplete, onUnexpectedContextError, asRoot, cacheable, parent, prepare);
    	if (_parserError != null) {
    		var e2:String = _parserError;
    		_parserError = null;
    		fail(e2);  		
    	} else if (_parser == null) {
    		fail("Missing complete event");
    	}
		_context = _parser.applicationContext;
    	assertNotNull("Expecting context instance", _context);
    	return _context;
    }
    
	protected function parseForContextError (name:String, xml:XML, asRoot:Boolean = false) : void {
    	_parser = null;
    	_context = null;
    	startParser(name, xml, onContextComplete, onUnexpectedContextError, asRoot);
    	if (_parserError == null) {
    		fail("Missing error event");
    	} else {
    		_parserError == null;
    	}
    }
    
    protected function parseForSingleObject2 (name:String, xml:XML, expectedType:Class) : Object {
    	var context:ApplicationContext = parseForContext2(name, xml);
    	assertEquals("Expecting 1 object in context", 1, context.objectCount);
    	var obj:Object = context.getObject(name);
    	assertNotNull("Expecting Object instance", obj);
    	if (!(obj is expectedType)) {
    		fail("Expected instance of type " + getQualifiedClassName(expectedType));
    	} 
    	return obj;
    }
    
    protected function get currentContext () : ApplicationContext {
    	return _context;
    }
    
    private function onContextComplete (event:Event) : void {
    	_parser = event.target as ApplicationContextParser;
    }
    
    protected function onUnexpectedContextError (event:ErrorEvent) : void {
    	_parserError = "Unexpected error parsing context: " + event.text;
    }
    
	
}

}