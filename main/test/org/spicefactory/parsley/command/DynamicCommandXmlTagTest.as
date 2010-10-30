package org.spicefactory.parsley.command {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.util.XmlContextUtil;

/**
 * @author Jens Halm
 */
public class DynamicCommandXmlTagTest extends DynamicCommandTestBase {
	
	
	[BeforeClass]
	public static function prepareFactory () : void {
		CommandTestBase.registerMockCommandFactory();
		ClassInfo.cache.purgeAll();
	}
	
	public override function get commandContext () : Context {
		return XmlContextUtil.newContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<dynamic-command 
			type="org.spicefactory.parsley.command.model.DynamicCommand" 
			message-type="org.spicefactory.parsley.messaging.messages.TestEvent" 
			selector="command1"
		/>

		<dynamic-command 
			type="org.spicefactory.parsley.command.model.DynamicCommand" 
			message-type="org.spicefactory.parsley.messaging.messages.TestEvent" 
			selector="command2" 
			stateful="true" 
			error="errorHandler"
		/>
			
		<dynamic-command 
			type="org.spicefactory.parsley.command.model.DynamicCommand" 
			message-type="org.spicefactory.parsley.messaging.messages.TestEvent" 
			selector="command3"
			>
			<property name="prop" value="9"/>
			<destroy method="destroy"/>
		</dynamic-command>
		
	</objects>;	
}
}
