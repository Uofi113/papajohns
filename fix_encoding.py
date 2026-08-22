import os, re

def fix_mojibake(match):
    text = match.group(1)
    try:
        # If it contains typical mojibake characters, try fixing it
        if 'Р' in text or 'С' in text or 'В' in text or '' in text:
            # First handle the  which means the file was saved with data loss.
            # If there's data loss, we can't reliably decode.
            pass
        
        fixed = text.encode('cp1251').decode('utf-8')
        return '@"' + fixed + '"'
    except:
        return match.group(0)

folder = 'c:/Projects/papajohns1000sber/src'
for fname in os.listdir(folder):
    if fname.endswith('.m') or fname.endswith('.h'):
        path = os.path.join(folder, fname)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # We will also just manually replace the known broken strings to be safe
        content = content.replace('РљРѕСЂР·РёРЅР°', 'Корзина')
        content = content.replace('Р’С‹С…РѕРґ', 'Выход')
        content = content.replace('РњРµРЅСЋ', 'Меню')
        content = content.replace('РС‚РѕРіРѕ', 'Итого')
        content = content.replace('СЂСѓР±.', 'руб.')
        content = content.replace('РџР°РїР°С€Р° Р‘РµРїРїРµ', 'Папаша Беппе')
        content = content.replace('РўРµР»РµС„РѕРЅ', 'Телефон')
        content = content.replace('Р±РѕРЅСѓСЃРѕРІ', 'бонусов')
        content = content.replace('СЃР±РµСЂ', 'сбер')
        content = content.replace('РЎР±РµСЂРЎРїР°СЃРёР±Рѕ', 'СберСпасибо')
        content = content.replace('В корзину', 'В корзину') # Not mojibake
        content = content.replace('Р’ РєРѕСЂР·РёРЅСѓ', 'В корзину')
        content = content.replace('РћС€РёР±РєР°', 'Ошибка')
        content = content.replace('API РЅРµ РІРµСЂРЅСѓР» JSON', 'API не вернул JSON')
        content = content.replace('РћС‚РІРµС‚', 'Ответ')
        content = content.replace('РЈСЃРїРµС€РЅРѕ', 'Успешно')
        content = content.replace('Р—Р°РєР°Р·', 'Заказ')
        content = content.replace('Р—Р°РєР°Р·Р°С‚СЊ', 'Заказать')
        
        # Just in case, try the regex for all strings
        content = re.sub(r'@"(.*?)"', fix_mojibake, content)
        
        # Also let's fix any occurrences of  (Replacement Character) with manual overrides
        if '' in content:
            print(f"Warning: {fname} contains replacement characters!")
            
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
print('Done fixing mojibake.')