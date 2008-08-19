package org.spicefactory.parsley.test.namespaces {
	
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.config.ApplicationContextParserTest;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ApplicationContextParser;
import org.spicefactory.parsley.namespaces.logging.LoggingNamespaceXml;
import org.spicefactory.parsley.context.ns.context_internal;
//import org.spicefactory.parsley.context.ns.context_internal;

public class LoggingTagsTest extends ApplicationContextParserTest {
	
	
	public override function setUp () : void {
		super.setUp();
		ApplicationContext.destroyAll();
		ApplicationContext.context_internal::setLocaleManager(null);
	}
	
	
	public function testLogFactoryConfig () : void {
		var xml:XML = <application-context 
			xmlns="http://www.spicefactory.org/parsley/1.0"
			xmlns:log="http://www.spicefactory.org/parsley/1.0/logging"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.spicefactory.org/parsley/1.0 http://www.spicefactory.org/parsley/schema/1.0/parsley-context.xsd http://www.spicefactory.org/parsley/1.0/logging http://www.spicefactory.org/parsley/schema/1.0/parsley-logging.xsd"
			>
    		<factory>
    			<log:factory id="logFactory" context="true">
    				<log:appender ref="appender" threshold="trace"/>
    				<log:logger name="foo" level="warn"/>
    				<log:logger name="foo.bar" level="off"/>
    				<log:logger name="log.debug" level="debug"/>
    				<log:logger name="log.info" level="info"/>
    				<log:logger name="log.error" level="error"/>
    				<log:logger name="log.fatal" level="fatal"/>
    			</log:factory>
    			<object id="appender" type="org.spicefactory.parsley.test.namespaces.LogCounterAppender"/>
    		</factory>
    	</application-context>;
    	var f:Function = function (parser:ApplicationContextParser) : void {
    		parser.addXml(LoggingNamespaceXml.config);
    	};
		var context:ApplicationContext = parseForContext2("logging", xml, false, false, null, f);
		assertEquals("Unexpected object count", 2, context.objectCount);
		logAllLevels(LogCounterAppender(context.getObject("appender")));
	}
	
	
	private function logAllLevels (counter:LogCounterAppender) : void {
		basicLoggerTest(counter, "foo", 3);
		basicLoggerTest(counter, "foo.bar", 0);
		basicLoggerTest(counter, "foo.other", 3);
		basicLoggerTest(counter, "other", 6);
		basicLoggerTest(counter, "log.debug", 5);
		basicLoggerTest(counter, "log.info", 4);
		basicLoggerTest(counter, "log.error", 2);
		basicLoggerTest(counter, "log.fatal", 1);
	}
	
	private function basicLoggerTest (counter:LogCounterAppender, 
			name:String, count:uint) : void {
		var msg:String = "The message does not matter";
		var logger:Logger = LogContext.getLogger(name);
		logger.trace(msg);
		logger.debug(msg);
		logger.info(msg);
		logger.warn(msg);
		logger.error(msg);
		logger.fatal(msg);
		assertEquals("Unexpected log count - logger: " + name, count, counter.getCount(name));
	}
	
	
}

}