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
    import com.adobe.cairngorm.navigation.core.InterceptorEvent;
    import com.adobe.cairngorm.navigation.core.NavigationActionName;
    import com.adobe.cairngorm.navigation.core.NavigationController;
    import com.adobe.cairngorm.navigation.core.NavigationParsleyAdaptor;
    import com.adobe.cairngorm.navigation.core.NavigationParsleyAdaptorFactory;
    import com.adobe.cairngorm.navigation.waypoint.WaypointHandler;
    
    import flash.events.Event;
    
    import org.spicefactory.lib.errors.IllegalStateError;
    import org.spicefactory.lib.reflect.ClassInfo;
    import org.spicefactory.lib.reflect.Method;
    import org.spicefactory.parsley.core.context.Context;
    import org.spicefactory.parsley.core.events.ContextEvent;
    import org.spicefactory.parsley.core.lifecycle.ManagedObject;
    import org.spicefactory.parsley.core.messaging.MessageProcessor;
    import org.spicefactory.parsley.core.registry.ObjectProcessor;
    import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
    import org.spicefactory.parsley.processor.util.ObjectProcessorFactories;

    public class NavigationProcessor implements ObjectProcessor
    {
        private var targetObject:ManagedObject;

        private var destination:String;

        private var controller:NavigationParsleyAdaptor;

        private var navigationParams:NavigationParameters;

        private var action:String;

        private var waypointHandler:WaypointHandler;

        private var target:Method;

        public function NavigationProcessor(targetObject:ManagedObject, params:NavigationParameters)
        {
            this.targetObject = targetObject;
            this.controller = NavigationParsleyAdaptorFactory.getInstance(params.scopeManager);
            this.navigationParams = params;
            this.action = navigationParams.action;
        }

        public static function newFactory(params:NavigationParameters):ObjectProcessorFactory
        {
            return ObjectProcessorFactories.newFactory(NavigationProcessor, [ params ]);
        }

        private function findDestinationFromLandmark():void
        {
            var factories:Array = targetObject.definition.processorFactories;
            for each (var item:ObjectProcessorFactory in factories)
            {
                if (item is LandmarkProcessorFactory)
                {
                    destination = LandmarkProcessorFactory(item).name;
                    break;
                }
            }
        }

        public function preInit():void
        {
            findDestinationFromLandmark();
			if(destination == null || destination == "")
			{
				throw new IllegalStateError("Could not find related Landmark defintion in class: " 
					+ targetObject.instance + " Each Enter/Exit defintion must relate to a Landmark defintion");	
			}
			
            var info:ClassInfo = navigationParams.typeInfo;
            target = info.getMethod(navigationParams.method);

            var navigation:NavigationController = controller.controller;

            if (action == NavigationActionName.ENTER)
            {
                action = findActionFromEnter();
            }
            var type:String = NavigationActionName.getEventName(destination, action);
            controller.addEventListener(type, waitForParsleyContext);

            navigation.registerDestination(destination, action);
        }

        private function findActionFromEnter():String
        {
            if (navigationParams.time == "first")
            {
                action = NavigationActionName.FIRST_ENTER;
            }
            else if (navigationParams.time == "next")
            {
                action = NavigationActionName.ENTER;
            }
            else if (navigationParams.time == "every")
            {
                action = NavigationActionName.EVERY_ENTER;
            }
            return action;
        }

        public function postDestroy():void
        {
            var type:String = NavigationActionName.getEventName(destination, action);
            controller.removeEventListener(type, waitForParsleyContext);
            NavigationParsleyAdaptorFactory.dispose(navigationParams.scopeManager);
        }

		private var pendingEvents:Array = new Array();
		
        private function waitForParsleyContext(event:Event):void
        {
			var context:Context = targetObject.context;
			if(context && context.configured && context.initialized)
			{
				navigationHandler(event);
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
				navigationHandler(pendingEvents[i]);
			}
			pendingEvents = new Array();
		}

        private function navigationHandler(event:Event):void
        {
            if (!navigationParams.isInterceptor)
            {
                invoke();
            }
            else
            {
                navigationHandlerInterceptor(event);
            }
        }

        private function navigationHandlerInterceptor(event:Event):void
        {
            invoke(InterceptorEvent(event).processor);
        }

        private function invoke(processor:MessageProcessor = null):void
        {
            if (processor)
            {
                target.invoke(targetObject.instance, [ processor ]);
            }
            else
            {
                target.invoke(targetObject.instance, []);
            }
        }
    }
}