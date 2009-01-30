package org.spicefactory.lib.logging {
import org.spicefactory.lib.logging.impl.DefaultLogFactory;

import flexunit.framework.TestCase;	

public class LoggingTest extends TestCase {
	
	
	
	public override function setUp () : void {
		super.setUp();
		var factory:LogFactory = new DefaultLogFactory();
		factory.setRootLogLevel(LogLevel.TRACE);
		factory.refresh();
		LogContext.factory = factory;	
	}
	
	
	
	public function testSingleAppender () : void {
		var counter:LogCounterAppender = new LogCounterAppender();
		LogContext.factory.addAppender(counter);
		logAllLevels(counter);
	}
	
	public function testTwoAppenders () : void {
		var counter1:LogCounterAppender = new LogCounterAppender();
		var counter2:LogCounterAppender = new LogCounterAppender();
		counter2.threshold = LogLevel.WARN;
		LogContext.factory.addAppender(counter1);
		LogContext.factory.addAppender(counter2);
		logAllLevels(counter1);
		assertLogCount(counter2, "foo", 3);
		assertLogCount(counter2, "foo.bar", 0);
		assertLogCount(counter2, "foo.other", 3);
		assertLogCount(counter2, "other", 3);
		assertLogCount(counter2, "log.debug", 3);
		assertLogCount(counter2, "log.info", 3);
		assertLogCount(counter2, "log.error", 2);
		assertLogCount(counter2, "log.fatal", 1);			
	}
	
	public function testSwitchContextFactory () : void {
		var counter:LogCounterAppender = new LogCounterAppender();
		LogContext.factory.addAppender(counter);
		var logger:Logger = LogContext.getLogger("foo");
		log(logger);
		assertEquals("Unexpected log count", 6, counter.getCount("foo"));
		
		var counter2:LogCounterAppender = new LogCounterAppender();
		var factory:LogFactory = new DefaultLogFactory();
		factory.setRootLogLevel(LogLevel.TRACE);
		factory.addAppender(counter2);
		factory.addLogLevel("foo", LogLevel.ERROR);
		factory.refresh();
		LogContext.factory = factory;
		log(logger);
		assertEquals("Unexpected log count", 2, counter2.getCount("foo"));
	}
	
	public function testClassInstanceAsLoggerName () : void {
		var counter:LogCounterAppender = new LogCounterAppender();
		LogContext.factory.addAppender(counter);
		var logger:Logger = LogContext.getLogger(LoggingTest);
		log(logger);
		assertEquals("Unexpected log count", 6, counter.getCount("org.spicefactory.lib.logging::LoggingTest"));
	}
	
	private function basicLoggerTest (counter:LogCounterAppender, 
			name:String, level:LogLevel, count:uint) : void {
		if (level != null) {
			LogContext.factory.addLogLevel(name, level);
			LogContext.factory.refresh();
		}	
		log(LogContext.getLogger(name));
		assertEquals("Unexpected log count - logger: " + name, count, counter.getCount(name));
	}
	
	private function assertLogCount (counter:LogCounterAppender, name:String, count:uint) : void {
		assertEquals("Unexpected log count - logger: " + name, count, counter.getCount(name));
	}
	
	private function logAllLevels (counter:LogCounterAppender) : void {
		basicLoggerTest(counter, "foo", LogLevel.WARN, 3);
		basicLoggerTest(counter, "foo.bar", LogLevel.OFF, 0);
		basicLoggerTest(counter, "foo.other", null, 3);
		basicLoggerTest(counter, "other", null, 6);
		basicLoggerTest(counter, "log.debug", LogLevel.DEBUG, 5);
		basicLoggerTest(counter, "log.info", LogLevel.INFO, 4);
		basicLoggerTest(counter, "log.error", LogLevel.ERROR, 2);
		basicLoggerTest(counter, "log.fatal", LogLevel.FATAL, 1);
	}
	
	
	private function log (logger:Logger) : void {
		var msg:String = "The message does not matter";
		logger.trace(msg);
		logger.debug(msg);
		logger.info(msg);
		logger.warn(msg);
		logger.error(msg);
		logger.fatal(msg);
	}
	
	
	
}

}