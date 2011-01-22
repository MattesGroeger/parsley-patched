package suites {
import org.spicefactory.parsley.command.OverrideCommandResultTest;
import org.spicefactory.parsley.command.DynamicCommandScopeAndOrderTest;
import org.spicefactory.parsley.command.CommandMetadataTagTest;
import org.spicefactory.parsley.command.CommandMxmlTagTest;
import org.spicefactory.parsley.command.CommandXmlTagTest;
import org.spicefactory.parsley.command.DynamicCommandMxmlTagTest;
import org.spicefactory.parsley.command.DynamicCommandXmlTagTest;
import org.spicefactory.parsley.command.sync.SynchronousCommandTest;
import org.spicefactory.parsley.command.task.TaskCommandTest;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class CommandSuite {

	public var commandMeta:CommandMetadataTagTest;
	public var commandMxml:CommandMxmlTagTest;
	public var commandXml:CommandXmlTagTest;
	
	public var dynCommandMxml:DynamicCommandMxmlTagTest;
	public var dynCommandXml:DynamicCommandXmlTagTest;
	
	public var order:DynamicCommandScopeAndOrderTest;
	public var overrideResult:OverrideCommandResultTest;
	public var commandTask:TaskCommandTest;
	public var commandSync:SynchronousCommandTest;
		
}
}
