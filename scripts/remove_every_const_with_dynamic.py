import re

path = '/Users/abhay/Desktop/QuantaForze/Acadyk/apps/mobile/lib/features/feed/presentation/screens/home_feed_screen.dart'

with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Replace any 'const ' before widget names (capitalized words) that contain any dynamic variables in their subtree
dynamic_tokens = ['textMain', 'textSub', 'iconColor', 'scaffoldBg', 'cardBg', 'borderDivider']

# We can perform regex replaces matching 'const [A-Z]\w*\(' and check if dynamic_tokens exist before closing brace
# Better yet, remove 'const ' from all Column, Row, Padding, Container, SizedBox, Text, Icon, Wrap, Stack, Positioned, Card, ListTile, SingleChildScrollView, Center, Align if they contain any dynamic token in their text block.

def clean_const(match):
    full_str = match.group(0)
    if any(tok in full_str for tok in dynamic_tokens):
        return re.sub(r'\bconst\s+', '', full_str)
    return full_str

# Match const constructors with parens
pattern = r'const\s+[A-Z]\w*\s*\([^;]*?\)'
for _ in range(5):
    code = re.sub(pattern, clean_const, code, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)

print("Finished recursively stripping const from dynamic subtrees")
