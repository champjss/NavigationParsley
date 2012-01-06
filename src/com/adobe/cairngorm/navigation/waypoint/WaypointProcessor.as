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
package com.adobe.cairngorm.navigation.waypoint
{
    import com.adobe.cairngorm.navigation.NavigationEvent;
    import com.adobe.cairngorm.navigation.core.NavigationParsleyAdaptor;
    import com.adobe.cairngorm.navigation.core.NavigationParsleyAdaptorFactory;
    import com.adobe.cairngorm.navigation.state.SelectedStatesFactory;
    
    import flash.system.ApplicationDomain;
    
    import mx.core.UIComponent;
    
    import org.spicefactory.lib.reflect.ClassInfo;
    import org.spicefactory.parsley.core.context.Context;
    import org.spicefactory.parsley.core.events.ContextEvent;
    import org.spicefactory.parsley.core.lifecycle.ManagedObject;
    import org.spicefactory.parsley.core.registry.ObjectProcessor;
    import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
    import org.spicefactory.parsley.core.scope.ScopeManager;
    import org.spicefactory.parsley.processor.util.ObjectProcessorFactories;

    public class WaypointProcessor implements ObjectProcessor
    {
        private var targetObject:ManagedObject;

        private var type:Class;

        private var mode:String;

        private var name:String;

        private var scopeManager:ScopeManager;

        private var domain:ApplicationDomain;

        private var controller:NavigationParsleyAdaptor;

        private var waypointHandler:WaypointHandler;

        public function WaypointProcessor(targetObject:ManagedObject, type:Class,
                                          mode:String, name:String, scopeManager:ScopeManager,
                                          domain:ApplicationDomain)
        {
            this.targetObject = targetObject;
            this.type = type;
            this.mode = mode;
            this.name = name;
            this.scopeManager = scopeManager;
            this.domain = domain;

            controller = NavigationParsleyAdaptorFactory.getInstance(scopeManager);
        }

        public static function newFactory(type:Class,
                                          mode:String, name:String, scopeManager:ScopeManager,
                                          domain:ApplicationDomain):ObjectProcessorFactory
        {
            var params:Array = [ type, mode, name, scopeManager, domain ];
            return ObjectProcessorFactories.newFactory(WaypointProcessor, params);
        }

        public function preInit():void
        {
            var view:UIComponent = UIComponent(targetObject.instance);

            waypointHandler = new WaypointHandler(controller.controller, name);
            waypointHandler.addEventListener(NavigationEvent.NAVIGATE_TO, waitForParsleyContext);			
			waypointHandler.createWaypoint(view, mode, type, isWaypointType);
        }

        private function isWaypointType(waypointType:Class):Boolean
        {
            return ClassInfo.forClass(waypointType, domain).isType(IWaypoint)
        }
		
		private var pendingEvents:Array = new Array();
		
		private function waitForParsleyContext(event:NavigationEvent):void
		{
			var context:Context = targetObject.context;
			if(context && context.configured && context.initialized)
			{
				dispatchParsleyEvent(event);
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
				dispatchParsleyEvent(pendingEvents[i]);
			}
			pendingEvents = new Array();
		}

        private function dispatchParsleyEvent(event:NavigationEvent):void
        {
            scopeManager.dispatchMessage(event);
        }

        public function postDestroy():void
        {
            SelectedStatesFactory.dispose(waypointHandler.name);
			waypointHandler.removeEventListener(NavigationEvent.NAVIGATE_TO, waitForParsleyContext);
			waypointHandler.destroy();
        }
    }
}