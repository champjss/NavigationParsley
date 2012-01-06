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
package com.adobe.cairngorm.navigation.core
{
    import flash.utils.Dictionary;
    
    import org.spicefactory.parsley.core.messaging.MessageProcessor;

    public class MessageProcessorInterceptor
    {
        private var processors:Dictionary = new Dictionary(true);
		public var lastInterceptors:Dictionary = new Dictionary(true);
        
		private var dispatcher:NavigationParsleyAdaptor;
        
        public function MessageProcessorInterceptor(dispatcher:NavigationParsleyAdaptor)
        {
            this.dispatcher = dispatcher;
        }
        
        public function registerProcessor(destination:String, processor:MessageProcessor):void
        {
            processors[destination] = processor;
        }

        public function navigationHandler(event:NavigationActionEvent):void
        {
            var action:String = NavigationActionName.getAction(event.type);
            
            var customProcessor:NavigationMessageProcessor;
            var interceptorEvent:InterceptorEvent;
            if (action == NavigationActionName.ENTER_INTERCEPT)
            {				
                customProcessor = new NavigationMessageProcessor(
                    dispatcher, 
                    event.newDestination, 
                    event.finalDestination,  
                    action,
                    getProcessor(event.newDestination, event),
					getProcessor(event.finalDestination, event));
                
                interceptorEvent = new InterceptorEvent(event.type, customProcessor);
                dispatcher.dispatchEvent(interceptorEvent);
            }
            else if (action == NavigationActionName.EXIT_INTERCEPT)
            {				
                customProcessor = new NavigationMessageProcessor(
                    dispatcher,
                    event.oldDestination, 
                    event.finalDestination,  
                    action,
                    getProcessor(event.oldDestination, event),
                    getProcessor(event.newDestination, event));

                interceptorEvent = new InterceptorEvent(event.type, customProcessor);
                dispatcher.dispatchEvent(interceptorEvent);
            }
            else
            {
                dispatcher.dispatchEvent(event);
            }
        }
        
        public function getProcessor(destination:String, event:NavigationActionEvent=null):MessageProcessor
        {
            var processor:MessageProcessor = processors[destination];
            if(!processor && event)
            {
                processor = processors[event.finalDestination];
            }
            return processor;
        }
    }
}