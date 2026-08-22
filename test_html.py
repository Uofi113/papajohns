import urllib.request, re
req = urllib.request.Request('https://papajohns.ru/', headers={'User-Agent': 'Mozilla/5.0'})
try:
    html = urllib.request.urlopen(req).read().decode('utf-8')
    print("Length:", len(html))
    print(html[:500])
except Exception as e:
    print(e)