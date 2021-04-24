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

// 1ab8524a95f7bd82fb831daa3e8fdc57c2f996ae
// Feb 15, 2021

(() => {
  const isSecure = document.location.protocol.startsWith('https')

  // In headful on secure origins the permission should be "default", not "denied"
  if (isSecure) {
    utils.replaceGetterWithProxy(Notification, 'permission', {
      apply() {
        return 'default'
      }
    })
  }

  // Another weird behavior:
  // On insecure origins in headful the state is "denied",
  // whereas in headless it's "prompt"
  if (!isSecure) {
    const handler = {
      apply(target, ctx, args) {
        const param = (args || [])[0]

        const isNotifications =
          param && param.name && param.name === 'notifications'
        if (!isNotifications) {
          return utils.cache.Reflect.apply(...arguments)
        }

        return Promise.resolve(
          Object.setPrototypeOf(
            {
              state: 'denied',
              onchange: null
            },
            PermissionStatus.prototype
          )
        )
      }
    }
    // Note: Don't use `Object.getPrototypeOf` here
    utils.replaceWithProxy(Permissions.prototype, 'query', handler)
  }
})()
