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
    import org.spicefactory.lib.reflect.ClassInfo;
    import org.spicefactory.parsley.core.scope.ScopeManager;

    public class NavigationParameters
    {
        private var _time:String;

        private var _action:String;

        private var _isInterceptor:Boolean;

        private var _method:String;

        private var _scopeManager:ScopeManager;

        private var _typeInfo:ClassInfo;

        public function NavigationParameters(time:String, action:String, isInterceptor:Boolean,
                                             method:String, scopeManager:ScopeManager,
                                             typeInfo:ClassInfo)
        {
            _time = time;
            _action = action;
            _isInterceptor = isInterceptor;
            _method = method;
            _scopeManager = scopeManager;
            _typeInfo = typeInfo;
        }

        public function get typeInfo():ClassInfo
        {
            return _typeInfo;
        }

        public function get scopeManager():ScopeManager
        {
            return _scopeManager;
        }

        public function get method():String
        {
            return _method;
        }

        public function get isInterceptor():Boolean
        {
            return _isInterceptor;
        }

        public function get action():String
        {
            return _action;
        }

        public function get time():String
        {
            return _time;
        }

    }
}