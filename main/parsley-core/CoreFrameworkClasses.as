/*
 * Copyright 2008-2009 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package {
	import org.spicefactory.parsley.core.factory.impl.LocalFactoryRegistry;
	import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.asconfig.builder.ActionScriptObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.AsyncObjectDefinitionBuilder;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.impl.ChildContext;
import org.spicefactory.parsley.core.errors.ContextBuilderError;
import org.spicefactory.parsley.core.lifecycle.impl.DefaultObjectLifecycleManager;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessageProcessor;
import org.spicefactory.parsley.core.messaging.impl.DefaultMessageRouter;
import org.spicefactory.parsley.core.messaging.impl.MessageTargetSelection;
import org.spicefactory.parsley.core.registry.impl.DefaultObjectDefinitionRegistry;
import org.spicefactory.parsley.task.CompositeContextBuilderTask;

/**
 * @private 
 * 
 * Needed since unfortunately compc does not allow to combine include-namespaces with include-source.
 * Lists all classes that are not added through include-namespaces.
 * 
 * @author Jens Halm
 */
public class CoreFrameworkClasses {
	
	AsyncObjectDefinitionBuilder;
	ActionScriptObjectDefinitionBuilder;
	ContextBuilderError;
	ChildContext;
	DefaultObjectLifecycleManager;
	CompositeContextBuilderTask;
	ActionScriptContextBuilder;
	DefaultCompositeContextBuilder;
	MessageTargetSelection;
	DefaultMessageProcessor;
	DefaultMessageRouter;
	DefaultObjectDefinitionRegistry;
	
	GlobalFactoryRegistry;
	LocalFactoryRegistry;
	
}
}
