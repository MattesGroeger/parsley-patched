package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.command.CommandTestBase;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class CommandXmlTagTest extends CommandTestBase {
	
	
	public override function get commandContext () : Context {
		return XmlContextTestBase.getXmlContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<object id="commandObservers" type="org.spicefactory.parsley.core.command.model.CommandObservers" lazy="true">
			<command-result method="noParam" type="org.spicefactory.parsley.core.messaging.TestEvent" selector="test1"/>
			<command-result method="oneParam" type="org.spicefactory.parsley.core.messaging.TestEvent" selector="test1"/>
			<command-result method="twoParams" selector="test1"/>
			<command-error method="error" type="org.spicefactory.parsley.core.messaging.TestEvent" selector="test1"/>
		</object> 
		
		<object id="commandExecutors" type="org.spicefactory.parsley.core.command.model.CommandExecutors" lazy="true">
			<command method="event1" selector="test1"/>
			<command method="event2" selector="test2"/>
			<command method="faultyCommand" selector="test1"/>
		</object> 
		
		<object id="commandStatusFlags" type="org.spicefactory.parsley.core.command.model.CommandStatusFlags" lazy="true">
			<command-status property="flag1and2" type="org.spicefactory.parsley.core.messaging.TestEvent"/>
			<command-status property="flag1" type="org.spicefactory.parsley.core.messaging.TestEvent" selector="test1"/>
			<command-status property="flag2" type="org.spicefactory.parsley.core.messaging.TestEvent" selector="test2"/>
		</object> 
		
	</objects>;	
}
}
