import urllib.request
try:
    req = urllib.request.Request('https://api.ollis.ru/', headers={'User-Agent': 'Mozilla/5.0'})
    print(urllib.request.urlopen(req, timeout=5).read().decode('utf-8')[:200])
except Exception as e:
    print(e)