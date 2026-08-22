import urllib.request, re
url = 'https://upload.wikimedia.org/wikipedia/en/thumb/d/d4/Papa_John%27s_Pizza_logo.svg/640px-Papa_John%27s_Pizza_logo.svg.png'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req) as response:
        with open('c:/Projects/papajohns1000sber/Resources/logo.png', 'wb') as f:
            f.write(response.read())
    print("Downloaded logo")
except Exception as e:
    print(e)