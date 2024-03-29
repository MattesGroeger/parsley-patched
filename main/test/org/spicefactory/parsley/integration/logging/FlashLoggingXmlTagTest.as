package org.spicefactory.parsley.integration.logging {
import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.LogCounterAppender;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.flash.logging.FlashLoggingXmlSupport;
import org.spicefactory.parsley.util.ContextTestUtil;
import org.spicefactory.parsley.util.XmlContextUtil;

public class FlashLoggingXmlTagTest {
	
	
	private static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley"
		xmlns:log="http://www.spicefactory.org/parsley/flash/logging"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd http://www.spicefactory.org/parsley/flash/logging http://www.spicefactory.org/parsley/schema/2.0/parsley-logging-flash.xsd"
		>
		<log:factory id="logFactory">
			<log:appender ref="appender" threshold="trace"/>
			<log:logger name="foo" level="warn"/>
			<log:logger name="foo.bar" level="off"/>
			<log:logger name="log.debug" level="debug"/>
			<log:logger name="log.info" level="info"/>
			<log:logger name="log.error" level="error"/>
			<log:logger name="log.fatal" level="fatal"/>
		</log:factory>
		<object id="appender" type="org.spicefactory.lib.logging.LogCounterAppender"/>
	</objects>;
	
	
	[Test]
	public function testLogFactoryConfig () : void {
		FlashLoggingXmlSupport.initialize();
		var context:Context = XmlContextUtil.newContext(config);
		var app:LogCounterAppender 
				= ContextTestUtil.getAndCheckObject(context, "appender", LogCounterAppender) as LogCounterAppender;
		logAllLevels(app);
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
		assertThat(counter.getCount(name), equalTo(count));
	}
	
	
}

}