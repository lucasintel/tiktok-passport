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
// Nov 21, 2020

(() => {
  /**
   * Input might look funky, we need to normalize it so e.g. whitespace isn't an issue for our spoofing.
   *
   * @example
   * video/webm; codecs="vp8, vorbis"
   * video/mp4; codecs="avc1.42E01E"
   * audio/x-m4a;
   * audio/ogg; codecs="vorbis"
   * @param {String} arg
   */
  const parseInput = arg => {
    const [mime, codecStr] = arg.trim().split(';')
    let codecs = []
    if (codecStr && codecStr.includes('codecs="')) {
      codecs = codecStr
        .trim()
        .replace(`codecs="`, '')
        .replace(`"`, '')
        .trim()
        .split(',')
        .filter(x => !!x)
        .map(x => x.trim())
    }
    return {
      mime,
      codecStr,
      codecs
    }
  }

  const canPlayType = {
    // Intercept certain requests
    apply: function(target, ctx, args) {
      if (!args || !args.length) {
        return target.apply(ctx, args)
      }
      const { mime, codecs } = parseInput(args[0])
      // This specific mp4 codec is missing in Chromium
      if (mime === 'video/mp4') {
        if (codecs.includes('avc1.42E01E')) {
          return 'probably'
        }
      }
      // This mimetype is only supported if no codecs are specified
      if (mime === 'audio/x-m4a' && !codecs.length) {
        return 'maybe'
      }

      // This mimetype is only supported if no codecs are specified
      if (mime === 'audio/aac' && !codecs.length) {
        return 'probably'
      }
      // Everything else as usual
      return target.apply(ctx, args)
    }
  }

  /* global HTMLMediaElement */
  utils.replaceWithProxy(
    HTMLMediaElement.prototype,
    'canPlayType',
    canPlayType
  )
})()
