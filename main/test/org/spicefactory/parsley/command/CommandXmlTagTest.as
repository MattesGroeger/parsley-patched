package org.spicefactory.parsley.command {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.util.XmlContextUtil;

/**
 * @author Jens Halm
 */
public class CommandXmlTagTest extends CommandTestBase {
	
	
	[BeforeClass]
	public static function prepareFactory () : void {
		registerMockCommandFactory();
		ClassInfo.cache.purgeAll();
	}
	
	public override function get commandContext () : Context {
		return XmlContextUtil.newContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="commandObservers" type="org.spicefactory.parsley.command.model.CommandObservers" lazy="true">
			<command-result method="noParam" type="org.spicefactory.parsley.messaging.messages.TestEvent" selector="test1"/>
			<command-result method="oneParam" type="org.spicefactory.parsley.messaging.messages.TestEvent" selector="test1"/>
			<command-result method="twoParams" selector="test1"/>
			<command-complete method="oneParamComplete" selector="test1"/>
			<command-error method="error" type="org.spicefactory.parsley.messaging.messages.TestEvent" selector="test1"/>
		</object> 
		
		<object id="commandExecutors" type="org.spicefactory.parsley.command.model.CommandExecutors" lazy="true">
			<command method="event1" selector="test1"/>
			<command method="event2" selector="test2"/>
			<command method="faultyCommand" selector="test1"/>
		</object> 
		
		<object id="commandStatusFlags" type="org.spicefactory.parsley.command.model.CommandStatusFlags" lazy="true">
			<command-status property="flag1and2" type="org.spicefactory.parsley.messaging.messages.TestEvent"/>
			<command-status property="flag1" type="org.spicefactory.parsley.messaging.messages.TestEvent" selector="test1"/>
			<command-status property="flag2" type="org.spicefactory.parsley.messaging.messages.TestEvent" selector="test2"/>
		</object> 
		
	</objects>;	
}
}
