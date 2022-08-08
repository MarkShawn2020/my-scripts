from main import url_view2raw


def test_url_view2raw():
    url_raw = 'https://raw.githubusercontent.com/GoogleChrome/chrome-extensions-samples/e716678b67fd30a5876a552b9665e9f847d6d84b/mv2-archive/extensions/speak_selection/background.js'
    url_view = 'https://github.com/GoogleChrome/chrome-extensions-samples/blob/e716678b67fd30a5876a552b9665e9f847d6d84b/mv2-archive/extensions/speak_selection/background.js'
    url_raw_converted = url_view2raw(url_view)
    print(url_raw_converted)
    assert url_raw_converted == url_raw
