// The MIT License (MIT)
//
// Copyright (c) 2019 berstend <github@berstend.com>
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
  if (!window.chrome) {
    // Use the exact property descriptor found in headful Chrome
    // fetch it via `Object.getOwnPropertyDescriptor(window, 'chrome')`
    Object.defineProperty(window, 'chrome', {
      writable: true,
      enumerable: true,
      configurable: false, // note!
      value: {} // We'll extend that later
    })
  }

  // That means we're running headful and don't need to mock anything
  if ('app' in window.chrome) {
    return // Nothing to do here
  }

  const makeError = {
    ErrorInInvocation: fn => {
      const err = new TypeError(`Error in invocation of app.${fn}()`)
      return utils.stripErrorWithAnchor(
        err,
        `at ${fn} (eval at <anonymous>`
      )
    }
  }

  // There's a some static data in that property which doesn't seem to change,
  // we should periodically check for updates: `JSON.stringify(window.app, null, 2)`
  const STATIC_DATA = JSON.parse(
    `
{
  "isInstalled": false,
  "InstallState": {
    "DISABLED": "disabled",
    "INSTALLED": "installed",
    "NOT_INSTALLED": "not_installed"
  },
  "RunningState": {
    "CANNOT_RUN": "cannot_run",
    "READY_TO_RUN": "ready_to_run",
    "RUNNING": "running"
  }
}
    `.trim()
  )

  window.chrome.app = {
    ...STATIC_DATA,

    get isInstalled() {
      return false
    },

    getDetails: function getDetails() {
      if (arguments.length) {
        throw makeError.ErrorInInvocation(`getDetails`)
      }
      return null
    },
    getIsInstalled: function getDetails() {
      if (arguments.length) {
        throw makeError.ErrorInInvocation(`getIsInstalled`)
      }
      return false
    },
    runningState: function getDetails() {
      if (arguments.length) {
        throw makeError.ErrorInInvocation(`runningState`)
      }
      return 'cannot_run'
    }
  }
  utils.patchToStringNested(window.chrome.app)
})()
