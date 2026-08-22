import os, re
path = 'c:/Projects/papajohns1000sber/src/PJMenuViewController.m'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'// Кнопка логаут.*?self.navigationItem.leftBarButtonItem = logoutBtn;', 'self.navigationItem.leftBarButtonItem = nil;', content, flags=re.DOTALL)
content = re.sub(r'- \(void\)_logout \{.*?\}', '', content, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)