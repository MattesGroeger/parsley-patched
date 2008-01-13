package org.spicefactory.parsley.test.localization {
	
	
import flash.events.ErrorEvent;
import flash.net.SharedObject;

import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.parsley.config.ApplicationContextParserTest;
import org.spicefactory.parsley.config.testmodel.ClassA;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.localization.Locale;
import org.spicefactory.parsley.localization.events.LocaleSwitchEvent;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;

public class LocalizationTest extends ApplicationContextParserTest {
	
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
		var lso:SharedObject = SharedObject.getLocal("__locale__");
		delete lso.data.locale;
	}
	
	public function testGetMessageIgnoreCountry () : void {
		ApplicationContext.context_internal::setLocaleManager(null);		
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
		    <setup>
		        <localization>
		            <locale-manager>
			            <default-locale language="en" country="US"/>
			            <locale language="de" country="DE"/>
			            <locale language="fr" country="FR"/>
			        </locale-manager>
			        <message-source>
			            <message-bundle id="test" basename="testBundle" localized="true" ignore-country="true"/>
			        </message-source>
		        </localization>
		    </setup>
    	</application-context>;  
    	var f:Function = addAsync(onTestGetMessageIgnoreCountry, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("messageIgnoreCountry");
		parser.addXml(xml);
		parser.addEventListener(ErrorEvent.ERROR, onUnexpectedContextError);
		parser.addEventListener(TaskEvent.COMPLETE, f);
		parser.start();
	}
	
	private function onTestGetMessageIgnoreCountry (event:TaskEvent) : void {
		var parser:ApplicationContextParser = ApplicationContextParser(event.target);
		var context:ApplicationContext = parser.applicationContext;
		assertEquals("Unexpected object count", 0, context.objectCount);
    	assertEquals("Unexpected message", "2 + 2 = 4", context.getMessage("test", "test", [2,2,4]));	
	}
	
	public function testGetLocalizedMessage () : void {
		ApplicationContext.context_internal::setLocaleManager(null);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
		    <setup>
		        <localization>
		            <locale-manager>
			            <default-locale language="en" country="US"/>
			            <locale language="de" country="DE"/>
			            <locale language="fr" country="FR"/>
			        </locale-manager>
			        <message-source>
			            <message-bundle id="test" basename="testBundle" localized="true"/>
			        </message-source>
		        </localization>
		    </setup>
    	</application-context>;  
    	var f:Function = addAsync(onTestGetLocalizedMessage, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("localizedMessage");
		parser.addXml(xml);
		parser.addEventListener(ErrorEvent.ERROR, onUnexpectedContextError);
		parser.addEventListener(TaskEvent.COMPLETE, f);
		parser.start();
	}
	
	private function onTestGetLocalizedMessage (event:TaskEvent) : void {
		var parser:ApplicationContextParser = ApplicationContextParser(event.target);
		var context:ApplicationContext = parser.applicationContext;
		assertEquals("Unexpected object count", 0, context.objectCount);
    	assertEquals("Unexpected message", "USA", context.getMessage("us", "test"));	
	}
	
	public function testDefaultBundle () : void {
		ApplicationContext.context_internal::setLocaleManager(null);
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
		    <setup>
		        <localization>
		            <locale-manager>
			            <default-locale language="en" country="US"/>
			            <locale language="de" country="DE"/>
			            <locale language="fr" country="FR"/>
			        </locale-manager>
			        <message-source>
			            <default-message-bundle id="test" basename="testBundle" localized="true"/>
			        </message-source>
		        </localization>
		    </setup>
    	</application-context>;  
    	var f:Function = addAsync(onTestDefaultBundle, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("defaultBundle");
		parser.addXml(xml);
		parser.addEventListener(ErrorEvent.ERROR, onUnexpectedContextError);
		parser.addEventListener(TaskEvent.COMPLETE, f);
		parser.start();
	}
	
	private function onTestDefaultBundle (event:TaskEvent) : void {
		var parser:ApplicationContextParser = ApplicationContextParser(event.target);
		var context:ApplicationContext = parser.applicationContext;
		assertEquals("Unexpected object count", 0, context.objectCount);
		var supportedLocales:Array = ApplicationContext.localeManager.supportedLocales;
		assertEquals("Unexpected number of supported locales", 3, supportedLocales.length);
    	assertEquals("Unexpected message", "USA", context.getMessage("us"));	
	}
	
	public function testProgrammaticDefaultLocale () : void {
		ApplicationContext.context_internal::setLocaleManager(null);		
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
		    <setup>
		        <localization>
		            <locale-manager>
			            <locale language="en" country="US"/>
			            <locale language="de" country="DE"/>
			            <locale language="fr" country="FR"/>
			        </locale-manager>
			        <message-source>
			            <message-bundle id="test" basename="testBundle" localized="true" ignore-country="true"/>
			        </message-source>
		        </localization>
		    </setup>
    	</application-context>;  
    	var f:Function = addAsync(onTestProgrammaticDefaultLocale, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("programmaticDefaultLocale");
		parser.locale = new Locale("de", "DE");
		parser.addXml(xml);
		parser.addEventListener(ErrorEvent.ERROR, onUnexpectedContextError);
		parser.addEventListener(TaskEvent.COMPLETE, f);
		parser.start();
	}
	
	private function onTestProgrammaticDefaultLocale (event:TaskEvent) : void {
		var parser:ApplicationContextParser = ApplicationContextParser(event.target);
		var context:ApplicationContext = parser.applicationContext;
		assertEquals("Unexpected object count", 0, context.objectCount);
    	assertEquals("Unexpected message", "Drei Worte Deutsch", context.getMessage("test", "test"));	
	}
	
	public function testMessageBinding () : void {
		ApplicationContext.context_internal::setLocaleManager(null);		
		var xml:XML = <application-context xmlns="http://www.spicefactory.org/parsley/1.0">
		    <setup>
		        <localization>
		            <locale-manager>
			            <default-locale language="en" country="US"/>
			            <locale language="de" country="DE"/>
			            <locale language="fr" country="FR"/>
			        </locale-manager>
			        <message-source>
			            <message-bundle id="test" basename="testBundle" localized="true" ignore-country="true"/>
			        </message-source>
		        </localization>
		    </setup>
		    <factory>
		    	<object id="binding" type="org.spicefactory.parsley.config.testmodel.ClassA">
		    		<property name="stringProp">
		    			<message-binding key="bind" bundle="test"/>
		    		</property>
		    	</object>
		    </factory>
    	</application-context>;  
    	var f:Function = addAsync(onTestMessageBinding, 3000);		
		var parser:ApplicationContextParser = new ApplicationContextParser("messageBinding");
		parser.addXml(xml);
		parser.addEventListener(ErrorEvent.ERROR, onUnexpectedContextError);
		parser.addEventListener(TaskEvent.COMPLETE, f);
		parser.start();
	}
	
	private function onTestMessageBinding (event:TaskEvent) : void {
		var parser:ApplicationContextParser = ApplicationContextParser(event.target);
		var context:ApplicationContext = parser.applicationContext;
		assertEquals("Unexpected object count", 1, context.objectCount);
		var obj:Object = context.getObject("binding");
		assertNotNull("Expected object", obj);
		var classA:ClassA = ClassA(obj);
    	assertEquals("Unexpected message", "English", classA.stringProp);	
    	var f:Function = addAsync(onSwitchLocale, 3000);
    	ApplicationContext.localeManager.addEventListener(LocaleSwitchEvent.COMPLETE, f);
    	ApplicationContext.localeManager.currentLocale = new Locale("de", "DE");
	}
	
	private function onSwitchLocale (event:LocaleSwitchEvent) : void {
		var context:ApplicationContext = ApplicationContext.forName("messageBinding");
		var classA:ClassA = ClassA(context.getObject("binding"));
		assertEquals("Unexpected message", "Deutsch", classA.stringProp);
	}

		
}

}