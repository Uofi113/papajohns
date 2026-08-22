import urllib.request, urllib.parse, re
url = 'https://html.duckduckgo.com/html/?q=' + urllib.parse.quote('papajohns.ru api url')
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
resp = urllib.request.urlopen(req).read().decode('utf-8')
matches = re.findall(r'<a class="result__url" href="([^"]+)">', resp)
print(matches[:5])