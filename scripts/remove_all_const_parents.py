import re

path = '/Users/abhay/Desktop/QuantaForze/Acadyk/apps/mobile/lib/features/feed/presentation/screens/home_feed_screen.dart'

with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Replace any 'const' before widget constructors if the widget contains dynamic getters (textMain, textSub, iconColor, scaffoldBg, cardBg, borderDivider) anywhere in its block
# A safer approach: strip 'const' from widgets like Row, Column, Padding, Container, SizedBox, Text, Icon, GestureDetector, InkWell, Expanded, Flexible, Stack, Positioned, Wrap, Center, Align, ListTile, Card, CircleAvatar
widgets = ['Row', 'Column', 'Padding', 'Container', 'SizedBox', 'Text', 'Icon', 'GestureDetector', 'InkWell', 'Expanded', 'Flexible', 'Stack', 'Positioned', 'Wrap', 'Center', 'Align', 'ListTile', 'Card', 'CircleAvatar', 'TextStyle', 'Decoration', 'BoxDecoration']

for _ in range(10):
    for w in widgets:
        # Match const Widget(...) where inside there is textMain/textSub/iconColor/scaffoldBg/cardBg/borderDivider
        pattern = rf'const\s+{w}\s*\(([^()]*?\b(?:textMain|textSub|iconColor|scaffoldBg|cardBg|borderDivider)\b[^()]*?)\)'
        code = re.sub(pattern, rf'{w}(\1)', code, flags=re.DOTALL)

# Specific lines identified by compiler
lines = code.split('\n')
for idx in [296, 432, 441, 647, 656, 663, 717, 915, 969, 975, 1057, 1065, 1074, 1083, 1112, 1308, 1369, 1375, 1395, 1415, 3343, 3350, 3359, 4720, 4895]:
    if 0 <= idx < len(lines):
        lines[idx] = re.sub(r'const\s+', '', lines[idx])

code = '\n'.join(lines)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)

print("Finished stripping invalid const widget wrappers in home_feed_screen.dart")
