/*
 * Copyright 2010 the original author or authors.
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

package org.spicefactory.lib.xml.mapper {
import org.spicefactory.lib.errors.IllegalStateError;
import flash.utils.getQualifiedClassName;
import org.spicefactory.lib.xml.XmlObjectMapper;
import flash.utils.Dictionary;

/**
 * Internal registry for all choices available to a group of mappings.
 * 
 * @author Jens Halm
 */
public class ChoiceRegistry {

	
	private var choicesByType:Dictionary = new Dictionary();
	private var choicesById:Dictionary = new Dictionary();
	
	
	/**
	 * Returns the choice for the specified type.
	 * If such a choice does not exist yet, a new one will be created.
	 * 
	 * @param type the type to return the choice for
	 * @return the choice for the specified type
	 */
	public function getChoiceByType (type:Class) : Choice {
		if (choicesByType[type] == undefined) {
			choicesByType[type] = new Choice();
		}
		return choicesByType[type] as Choice;
	}
	
	/**
	 * Returns the choice for the specified id.
	 * If such a choice does not exist yet, a new one will be created.
	 * 
	 * @param id the id to return the choice for
	 * @return the choice for the specified id
	 */
	public function getChoiceById(id:String) : Choice {
		if (choicesById[id] == undefined) {
			choicesById[id] = new Choice();
		}
		return choicesById[id] as Choice;
	}

	
	/**
	 * Initializes all existing choices, extracting the corresponding mappers for
	 * all existing choices which map to types and their subtypes.
	 * Also validates all existing choices and throws an Error if one of them
	 * is empty.
	 * 
	 * @param mappers the mappings to fill the choices with, the keys in the Dictionary are the
	 * types (classes) of the mappings, the values are the actual mappers.
	 */
	public function initialize (mappers:Dictionary) : void {
		var invalidTypes:Array = new Array();
		var invalidIds:Array = new Array();
		for (var key:Object in choicesByType) {
			var type:Class = key as Class;
			var valid:Boolean = false;
			for each (var mapper:XmlObjectMapper in mappers) {
				if (mapper.objectType.isType(type)) {
					Choice(choicesByType[type]).addMapper(mapper);
					valid = true;
				}
			}
			if (!valid) {
				invalidTypes.push(getQualifiedClassName(type));
			}
		}
		for (var idKey:Object in choicesById) {
			var id:String = idKey as String;
			var choice:Choice = choicesById[id] as Choice;
			if (choice.getAllMappers().length == 0) {
				invalidIds.push(id);
			}
		}
		if (invalidTypes.length > 0 || invalidIds.length > 0) {
			var msg:String = "One or more Choices do not contain any mappings ";
			if (invalidTypes.length > 0) {
				msg += " - invalid types = " + invalidTypes.join(", ");
			}
			if (invalidIds.length > 0) {
				msg += " - invalid ids = " + invalidIds.join(", ");
			}
			throw new IllegalStateError(msg);
		}
	}

	/**
	 * Merges the content of this registry into the specified registry.
	 * 
	 * @param choices the registry to merge the content of this registry into
	 */
	public function mergeInto (choices:ChoiceRegistry) : void {
		for (var idKey:Object in choicesById) {
			var id:String = idKey as String;
			var idChoice:Choice = choices.getChoiceById(id);
			mergeChoice(idChoice, Choice(choicesById[id]).getAllMappers());
		}
		for (var typeKey:Object in choicesByType) {
			var type:Class = typeKey as Class;
			var typeChoice:Choice = choices.getChoiceByType(type);
			mergeChoice(typeChoice, Choice(choicesByType[type]).getAllMappers());
		}
	}
	
	private function mergeChoice (choice:Choice, mappers:Array) : void {
		for each (var mapper:XmlObjectMapper in mappers) {
			choice.addMapper(mapper);
		}
	}
	
	
}
}
