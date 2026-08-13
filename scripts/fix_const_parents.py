import re

path = '/Users/abhay/Desktop/QuantaForze/Acadyk/apps/mobile/lib/features/feed/presentation/screens/home_feed_screen.dart'

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

dynamic_vars = {'textMain', 'textSub', 'iconColor', 'scaffoldBg', 'cardBg', 'borderDivider'}

# We will parse the file line by line and fix any line that has 'const ' before a constructor containing any of dynamic_vars
new_lines = []
for i, line in enumerate(lines):
    # Check if this line or near lines contain dynamic_vars
    has_dynamic = any(var in line for var in dynamic_vars)
    if has_dynamic:
        # Strip 'const ' from this line if present before a Widget constructor
        line = re.sub(r'const\s+([A-Z]\w*)\(', r'\1(', line)
    new_lines.append(line)

code = ''.join(new_lines)

# Also fix multiline const expressions: e.g. const Row(\n ... textMain ... \n)
# Let's repeatedly strip 'const ' before widgets that enclose textMain/textSub/iconColor
for _ in range(5):
    code = re.sub(r'const\s+([A-Z]\w*)\s*\(([^()]*?\b(?:textMain|textSub|iconColor|scaffoldBg|cardBg|borderDivider)\b[^()]*?)\)', r'\1(\2)', code, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)

print("Finished fixing const parent constructors in home_feed_screen.dart")
