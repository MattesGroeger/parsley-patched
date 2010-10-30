package suites {

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class MainSuite {
	
	public var spicelib:SpicelibSuite;
	public var reflection:ReflectionSuite;
	
	public var context:ContextSuite;
	public var config:ConfigSuite;
	public var coreTag:CoreTagSuite;

	public var lifecycle:LifecycleSuite;
	public var messaging:MessagingSuite;
	public var command:CommandSuite;
	public var binding:BindingSuite;

	public var integration:IntegrationSuite;
	
}
}
