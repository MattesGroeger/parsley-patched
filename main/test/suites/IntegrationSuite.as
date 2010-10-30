package suites {
import org.spicefactory.parsley.integration.logging.FlashLoggingXmlTagTest;
import org.spicefactory.parsley.integration.resources.FlashResourcesTest;
import org.spicefactory.parsley.integration.logging.FlexLoggingXmlTagTest;
import org.spicefactory.parsley.integration.pimento.PimentoMxmlTagTest;
import org.spicefactory.parsley.integration.pimento.PimentoXmlTagTest;

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class IntegrationSuite {

	public var flexLogging:FlexLoggingXmlTagTest;
	public var flashLogging:FlashLoggingXmlTagTest;
	public var flashResources:FlashResourcesTest;
	public var pimentoMxml:PimentoMxmlTagTest;
	public var pimentoXml:PimentoXmlTagTest;
	
}
}
