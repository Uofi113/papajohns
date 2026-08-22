import os
path = 'c:/Projects/papajohns1000sber/Makefile'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('src/PJAuthViewController.m \\', '')
content = content.replace('src/PJAuthViewController.m', '')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)