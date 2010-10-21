/*
 * Copyright 2009 the original author or authors.
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
import org.spicefactory.parsley.flex.tag.ContextAwareTagBase;
import org.spicefactory.parsley.flex.FlexConfig;
import org.spicefactory.parsley.flex.FlexContextBuilder;
import org.spicefactory.parsley.flex.FlexSupport;
import org.spicefactory.parsley.flex.logging.FlexLoggingXmlSupport;
import org.spicefactory.parsley.flex.resources.FlexResourceBindingAdapter;

/**
 * @private 
 * 
 * Needed since unfortunately compc does not allow to combine include-namespaces with include-source.
 * Lists all classes that are not added through include-namespaces.
 * 
 * @author Jens Halm
 */
public class FlexSupportClasses {
	
	FlexLoggingXmlSupport;
	FlexSupport;
	FlexResourceBindingAdapter;
	FlexContextBuilder;
	FlexConfig;
	ContextAwareTagBase;
	
}
}
