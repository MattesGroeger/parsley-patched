package org.spicefactory.parsley.sample.helloworld
{
	/**
	 * A single instance of this model is declared in the MXML configuration
	 * file. The same instance is then injected into both the SendModel and
	 * ReceiveModel.
	 */
	public class SharedModel
	{
		[Bindable]
		public var slogan:String = 
			"Parsley is simple, powerful and proven in the enterprise.";
	}
}