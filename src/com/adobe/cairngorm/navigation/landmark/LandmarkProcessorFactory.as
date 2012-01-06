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
    import org.spicefactory.lib.util.ClassUtil;
    import org.spicefactory.parsley.core.lifecycle.ManagedObject;
    import org.spicefactory.parsley.core.registry.ObjectProcessor;
    import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
    import org.spicefactory.parsley.core.scope.ScopeManager;

    public class LandmarkProcessorFactory implements ObjectProcessorFactory
    {
        private var _name:String;

        public function get name():String
        {
            return _name;
        }

        private var scopeManager:ScopeManager

        public function LandmarkProcessorFactory(name:String, scopeManager:ScopeManager)
        {
            _name = name;
            this.scopeManager = scopeManager;
        }

        public function createInstance(target:ManagedObject):ObjectProcessor
        {
            var args:Array = [ _name, scopeManager ];
            args.unshift(target);
            return ObjectProcessor(ClassUtil.createNewInstance(LandmarkProcessor,
                                                               args));
        }
    }
}