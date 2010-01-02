package org.spicefactory.parsley.xml {
import org.spicefactory.parsley.core.command.DynamicCommandTestBase;
import org.spicefactory.parsley.core.context.Context;

/**
 * @author Jens Halm
 */
public class DynamicCommandXmlTagTest extends DynamicCommandTestBase {
	
	
	public override function get commandContext () : Context {
		return XmlContextTestBase.getXmlContext(config);
	}
	
	public static const config:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley">
		
		<dynamic-command 
			type="org.spicefactory.parsley.core.command.model.DynamicCommand" 
			message-type="org.spicefactory.parsley.core.messaging.TestEvent" 
			selector="command1"
		/>

		<dynamic-command 
			type="org.spicefactory.parsley.core.command.model.DynamicCommand" 
			message-type="org.spicefactory.parsley.core.messaging.TestEvent" 
			selector="command2" 
			stateful="true" 
			error="errorHandler"
		/>
			
		<dynamic-command 
			type="org.spicefactory.parsley.core.command.model.DynamicCommand" 
			message-type="org.spicefactory.parsley.core.messaging.TestEvent" 
			selector="command3"
			>
			<property name="prop" value="9"/>
			<destroy method="destroy"/>
		</dynamic-command>
		
	</objects>;	
}
}
