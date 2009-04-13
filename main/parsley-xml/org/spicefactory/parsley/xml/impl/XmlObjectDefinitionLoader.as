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

package org.spicefactory.parsley.xml.impl {
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.task.ResultTask;
import org.spicefactory.lib.task.enum.TaskState;
import org.spicefactory.lib.task.events.TaskEvent;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.parsley.xml.tag.Include;
import org.spicefactory.parsley.xml.tag.Variable;

import flash.events.ErrorEvent;

/**
 * @author Jens Halm
 */
public class XmlObjectDefinitionLoader extends ResultTask {
	
	
	private static var log:Logger = LogContext.getLogger(XmlObjectDefinitionLoader);
	
	
	private var files:Array;
	private var loadedXml:Array = new Array();
	
	private var loaderTaskBuilder:XmlLoaderTaskBuilder;
	private var expressionContext:ExpressionContext;
	
	private var variableMapper:XmlObjectMapper;
	private var includeMapper:XmlObjectMapper; // TODO - create both

	
	function XmlObjectDefinitionLoader (files:Array, 
			expressionContext:ExpressionContext, loaderTaskBuilder:XmlLoaderTaskBuilder = null) {
		this.files = files;
		this.expressionContext = expressionContext;
		this.loaderTaskBuilder = (loaderTaskBuilder == null) ? new DefaultLoaderTaskBuilder() : loaderTaskBuilder;
		setRestartable(false);
		setSuspendable(false);
		setSkippable(false);
		setCancelable(true);
	}
	
	
	protected override function doStart () : void {
		loadNextFile();
	}
	
	private function loadNextFile () : void {
		if (files.length == 0) {
			setResult(loadedXml);
			return;
		}
		log.debug("Start loading next file: " + files[0]);
		var loader:ResultTask = loaderTaskBuilder.createLoaderTask(files.shift());
		loader.addEventListener(TaskEvent.COMPLETE, fileLoaded);
		loader.addEventListener(ErrorEvent.ERROR, fileError);
		loader.start();
	}
	
	private function fileLoaded (event:TaskEvent) : void {
		if (state != TaskState.ACTIVE) return;
		var loader:ResultTask = ResultTask(event.target);
		var xml:XML = loader.result as XML;
		try {
			process(xml);
		} catch (e:Error) {
			log.error("Error parsing XML context definition", e);
			error(e.message);
			return;
		}
		loadedXml.push(xml);
		loadNextFile();
	}
	
	
	private function process (xml:XML) : void {
		for each (var variableXml:XML in xml.variable) {
			var variable:Variable = variableMapper.mapToObject(variableXml, context) as Variable;
			expressionContext.setVariable(variable.name, variable.value);
		}
		for each (var includeXml:XML in xml["include"]) {
			var incl:Include = includeMapper.mapToObject(includeXml, context) as Include;
			files.push(incl.filename);
		}
		delete xml.variable;
		delete xml["include"]; // to trick the FDT parser who comlains about xml.include
	}
	
	
	private function fileError (evt:ErrorEvent) : void {
		log.error(evt.text);
		error(evt.text);
	}
	
	
}
}

import org.spicefactory.lib.task.ResultTask;
import org.spicefactory.lib.task.util.XmlLoaderTask;

class DefaultLoaderTaskBuilder implements XmlLoaderTaskBuilder {

	public function createLoaderTask (file:String) : ResultTask {
		return new XmlLoaderTask(file);
	}
	
}

