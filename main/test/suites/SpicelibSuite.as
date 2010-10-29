package suites {
import org.spicefactory.lib.task.TaskTest;
import org.spicefactory.lib.expr.ExpressionTest;
import org.spicefactory.lib.logging.LoggingTest;
import org.spicefactory.lib.xml.MetadataMapperTest;
import org.spicefactory.lib.xml.PropertyMapperTest;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class SpicelibSuite {

	public var propertyMappers:PropertyMapperTest;
	public var metadataMappers:MetadataMapperTest;
	
	public var tasks:TaskTest;
	
	public var expressions:ExpressionTest;
	public var logging:LoggingTest;
	
}
}
