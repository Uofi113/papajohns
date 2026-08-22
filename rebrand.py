import os
def replace_in_file(path, old, new):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

folder = 'c:/Projects/papajohns1000sber/src'
for fname in os.listdir(folder):
    if fname.endswith('.m') or fname.endswith('.h'):
        replace_in_file(os.path.join(folder, fname), 'Papa Johns', 'Папаша Беппе')
        replace_in_file(os.path.join(folder, fname), 'Папа Джонс', 'Папаша Беппе')

replace_in_file('c:/Projects/papajohns1000sber/Makefile', 'PapaJohns', 'PapashaBeppe')
replace_in_file('c:/Projects/papajohns1000sber/Resources/Info.plist', '<string>Papa Johns</string>', '<string>Папаша Беппе</string>')
replace_in_file('c:/Projects/papajohns1000sber/Resources/Info.plist', '<string>PapaJohns</string>', '<string>PapashaBeppe</string>')
replace_in_file('c:/Projects/papajohns1000sber/control', 'Papa Johns', 'Папаша Беппе')
replace_in_file('c:/Projects/papajohns1000sber/control', 'com.uofist.papajohns', 'com.uofist.papashabeppe')