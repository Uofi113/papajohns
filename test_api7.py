import urllib.request
try:
    req = urllib.request.Request('https://api-facade.papajohns.ru/api/v1/catalog/menu', headers={'User-Agent': 'Mozilla/5.0'})
    print(urllib.request.urlopen(req).read().decode('utf-8')[:200])
except Exception as e:
    print("facade menu:", e)

try:
    req = urllib.request.Request('https://api.papajohns.ru/catalog/menu', headers={'User-Agent': 'Mozilla/5.0', 'Accept': 'application/json'})
    print(urllib.request.urlopen(req).read().decode('utf-8')[:200])
except Exception as e:
    print("api menu:", e)