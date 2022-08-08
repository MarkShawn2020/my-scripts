import requests

url = 'https://cs.android.com/android/platform/superproject/+/android-7.0.0_r1:frameworks/native/services/surfaceflinger/'


res = requests.get(url)

print(res.text)
