package org.spicefactory.parsley.integration.pimento {
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.rpc.cinnamon.config.CinnamonXmlSupport;
import org.spicefactory.parsley.rpc.pimento.config.PimentoXmlSupport;
import org.spicefactory.parsley.util.XmlContextUtil;

public class PimentoXmlTagTest extends PimentoTestBase {

	
	CinnamonXmlSupport.initialize();
	PimentoXmlSupport.initialize();
	
	
	public override function get pimentoContext () : Context {
		return XmlContextUtil.newContext(pimentoXml);
	}
	
	public override function get cinnamonContext () : Context {
		return XmlContextUtil.newContext(cinnamonXml);
	}
	
	public var cinnamonXml:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley"
		xmlns:cinnamon="http://www.spicefactory.org/parsley/cinnamon"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd http://www.spicefactory.org/parsley/cinnamon http://www.spicefactory.org/parsley/schema/2.0/parsley-cinnamon.xsd"
		>
		<cinnamon:channel 
		    id="mainChannel"
		    url="http://localhost:8080/Pimento_Server/cinnamon/"
		    timeout="3000"
		/>
		<cinnamon:service
		    name="echoService"
		    type="org.spicefactory.parsley.integration.pimento.model.EchoServiceImpl"
		/>
	</objects>;
		
	public var pimentoXml:XML = <objects 
		xmlns="http://www.spicefactory.org/parsley"
		xmlns:pimento="http://www.spicefactory.org/parsley/pimento"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.spicefactory.org/parsley http://www.spicefactory.org/parsley/schema/2.0/parsley-core.xsd http://www.spicefactory.org/parsley/pimento http://www.spicefactory.org/parsley/schema/2.0/parsley-pimento.xsd"
		>
		<pimento:config 
		    url="http://localhost:8080/Pimento_Server/cinnamon/"
		    timeout="3000"
		/>
		<pimento:service
		    name="echoService"
		    type="org.spicefactory.parsley.integration.pimento.model.EchoServiceImpl"
		/>
	</objects>;
	
}

}