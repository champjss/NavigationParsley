/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.navigation.landmark
{
    import com.adobe.cairngorm.navigation.core.NavigationActionEvent;
    import com.adobe.cairngorm.navigation.core.NavigationParsleyAdaptor;
    import com.adobe.cairngorm.navigation.core.NavigationParsleyAdaptorFactory;
    import com.adobe.cairngorm.navigation.state.SelectedStates;
    import com.adobe.cairngorm.navigation.state.SelectedStatesFactory;
    
    import org.spicefactory.parsley.core.context.Context;
    import org.spicefactory.parsley.core.events.ContextEvent;
    import org.spicefactory.parsley.core.lifecycle.ManagedObject;
    import org.spicefactory.parsley.core.registry.ObjectProcessor;
    import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
    import org.spicefactory.parsley.core.scope.ScopeManager;

    public class LandmarkProcessor implements ObjectProcessor
    {
        private var targetObject:ManagedObject;

        private var _name:String;

        public function get name():String
        {
            return _name;
        }

        private var scopeManager:ScopeManager;

        private var controller:NavigationParsleyAdaptor;

        public function LandmarkProcessor(targetObject:ManagedObject, name:String,
                                          scopeManager:ScopeManager)
        {
            this.targetObject = targetObject;
            _name = name;
            this.scopeManager = scopeManager;

            controller = NavigationParsleyAdaptorFactory.getInstance(scopeManager);
            controller.addEventListener(name, waitForParsleyContext);
        }

        public static function newFactory(name:String,
                                          scopeManager:ScopeManager):ObjectProcessorFactory
        {
            return new LandmarkProcessorFactory(name, scopeManager);
        }

        public function preInit():void
        {
            var state:SelectedStates = SelectedStatesFactory.getInstance(name);
            state.subscribe(targetObject.instance);
        }

        public function postDestroy():void
        {
            var state:SelectedStates = SelectedStatesFactory.getInstance(name);
            state.unsubscribe(targetObject.instance);

            controller.removeEventListener(name, waitForParsleyContext);
        }
		
		private var pendingEvents:Array = new Array();
		
		private function waitForParsleyContext(event:NavigationActionEvent):void
		{
			var context:Context = targetObject.context;
			if(context && context.configured && context.initialized)
			{
				landmarkChangeHandler(event);
			}
			else if(context && context.configured)
			{
				pendingEvents.push(event);
				context.addEventListener(ContextEvent.INITIALIZED, handleContextInitialized, false, 0, true);
			}
		}
		
		private function handleContextInitialized(event:ContextEvent):void
		{
			targetObject.context.removeEventListener(ContextEvent.INITIALIZED, handleContextInitialized);
			var length:int = pendingEvents.length;
			for(var i:int; i<length; i++)
			{
				landmarkChangeHandler(pendingEvents[i]);
			}
			pendingEvents = new Array();
		}

        private function landmarkChangeHandler(event:NavigationActionEvent):void
        {
            var state:SelectedStates = SelectedStatesFactory.getInstance(name);
            state.selectedName = event.newDestination;
        }
    }
}