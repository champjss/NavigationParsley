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
    import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
    import org.spicefactory.parsley.core.builder.ObjectDefinitionDecorator;
    import org.spicefactory.parsley.core.scope.ScopeManager;

    public class AbstractNavigationDecorator implements ObjectDefinitionDecorator
    {

        [Target]
        public var method:String;

        private var time:String;

        private var action:String;

        private var isInterceptor:Boolean;

        public function AbstractNavigationDecorator(action:String, isInterceptor:Boolean = false,
                                                    time:String = null)
        {
            this.action = action;
            this.isInterceptor = isInterceptor;
            this.time = time;
        }

        protected function decorateForEnter(builder:ObjectDefinitionBuilder, time:String):void
        {
            this.time = time;
            performDecorate(builder);
        }

        public function decorate(builder:ObjectDefinitionBuilder):void
        {
            performDecorate(builder);
        }

        private function performDecorate(builder:ObjectDefinitionBuilder):void
        {
            var scopeManager:ScopeManager = builder.registry.context.scopeManager;

            var params:NavigationParameters = new NavigationParameters(time, action,
                                                                       isInterceptor,
                                                                       method, scopeManager,
                                                                       builder.typeInfo);
			builder.process(new NavigationProcessor(params));
        }
    }
}