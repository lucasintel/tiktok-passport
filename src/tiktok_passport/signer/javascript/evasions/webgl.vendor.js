// The MIT License (MIT)
//
// Copyright (c) 2019 berstend <github@berstend.com>
// Copyright (c) 2020 diprajpatra
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// c44c8bb0224c6bba2554017bfb9d7a1d0119f92f
// Aug 21, 2020

(() => {
  const getParameterProxyHandler = {
    apply: function (target, ctx, args) {
      const param = (args || [])[0]
      // UNMASKED_VENDOR_WEBGL
      if (param === 37445) {
        return 'Intel Inc.' // default in headless: Google Inc.
      }
      // UNMASKED_RENDERER_WEBGL
      if (param === 37446) {
        return 'Intel Iris OpenGL Engine' // default in headless: Google SwiftShader
      }
      return utils.cache.Reflect.apply(target, ctx, args)
    }
  }

  // There's more than one WebGL rendering context
  // https://developer.mozilla.org/en-US/docs/Web/API/WebGL2RenderingContext#Browser_compatibility
  // To find out the original values here: Object.getOwnPropertyDescriptors(WebGLRenderingContext.prototype.getParameter)
  const addProxy = (obj, propName) => {
    utils.replaceWithProxy(obj, propName, getParameterProxyHandler)
  }
  // For whatever weird reason loops don't play nice with Object.defineProperty, here's the next best thing:
  addProxy(WebGLRenderingContext.prototype, 'getParameter')
  addProxy(WebGL2RenderingContext.prototype, 'getParameter')
  console.log('hi');
})()
