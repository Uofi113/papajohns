import os, re
path = 'c:/Projects/papajohns1000sber/src/PJCartViewController.m'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'- \(void\)_checkout \{.*?\n@end', '''- (void)_checkout {
    if ([PJCartManager sharedManager].totalCount == 0) return;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:+74012312312"]];
}
@end''', content, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)