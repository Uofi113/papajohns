import urllib.request, urllib.parse, re
url = 'https://html.duckduckgo.com/html/?q=' + urllib.parse.quote('папаша беппе калининград')
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    resp = urllib.request.urlopen(req).read().decode('utf-8')
    matches = re.findall(r'<a class="result__url" href="([^"]+)">', resp)
    print(matches[:5])
except Exception as e:
    print(e)