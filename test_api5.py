import urllib.request, json
req = urllib.request.Request('https://api.papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0'})
try:
    print("Trying api.papajohns.ru/")
    with urllib.request.urlopen(req) as response:
        print(response.read().decode('utf-8')[:200])
except Exception as e:
    print(e)