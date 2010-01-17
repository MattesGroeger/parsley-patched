package org.spicefactory.parsley.sample.helloworld
{
	/**
	 * This model is declared inside the MXML HelloWorldConfig file. It is then
	 * injected into the SendPanel view component.
	 */
	public class SendModel
	{
		[Bindable]
		public var initialized:Boolean;
		
		/** 
		 * The [Inject] metadata tells Parsley to inject a dependency by 
		 * searching the context for an object of matching type.
		 */
		[Inject]
		[Bindable]
		public var sharedModel:SharedModel;

		/**
		 * The [MessageDispatcher] metadata tells Parsley to configure the 
		 * function so it can be used to send (dispatch) messages.
		 */ 
		[MessageDispatcher]
		public var sendMessage:Function;
		
		/**
		 * The [Init] metadata tells Parsley to call the annotated method after 
		 * an instance of this object is created and configured.
		 */ 
		[Init]
		public function init() : void {
			initialized = true;
		}
		
		/**
		 * This method sends a message via the Parsley messaging framework. 
		 * Any kind of object can be sent as a message by passing it to a 
		 * message dispatcher function.
		 */
		public function sayHello() : void {
			sendMessage(new HelloWorldMessage());
		}
	}
}