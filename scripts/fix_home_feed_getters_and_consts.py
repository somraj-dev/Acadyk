import re

path = '/Users/abhay/Desktop/QuantaForze/Acadyk/apps/mobile/lib/features/feed/presentation/screens/home_feed_screen.dart'

with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Add theme getters to State classes that are missing them
getters_code = """
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get scaffoldBg => _isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  Color get cardBg => _isDark ? const Color(0xFF000000) : Colors.white;
  Color get textMain => _isDark ? const Color(0xFFF7F9F9) : const Color(0xFF0F1419);
  Color get textSub => _isDark ? const Color(0xFF71767B) : const Color(0xFF536471);
  Color get iconColor => _isDark ? Colors.white : Colors.black87;
  Color get borderDivider => _isDark ? const Color(0xFF2F3336) : const Color(0xFFEFF3F4);
"""

# Check for classes missing theme getters and add them
for state_class in ['_RepostScreenState', '_ReportPostScreenState', 'SharePostScreen', '_HomeFeedScreenState']:
    pattern = rf'class {state_class} (?:extends [^{{]+)\{{'
    if re.search(pattern, code):
        # Insert getters right after class declaration if not present
        if f'class {state_class}' in code and f'{state_class}_has_getters' not in code:
            code = re.sub(pattern, rf'class {state_class} extends State<{state_class.replace("_State", "").replace("State", "").replace("_", "")}> {{\n  // {state_class}_has_getters\n' + getters_code, code)

# 2. Fix invalid const expressions where dynamic variables (textMain, textSub, iconColor, borderDivider) are used inside const constructors
# Remove 'const' before Icon when iconColor or textMain or textSub is used
code = re.sub(r'const\s+Icon\(([^)]*?\b(?:textMain|textSub|iconColor|borderDivider)\b[^)]*?)\)', r'Icon(\1)', code)

# Remove 'const' before Text when textMain or textSub or iconColor is used
code = re.sub(r'const\s+Text\(([^)]*?\b(?:textMain|textSub|iconColor|borderDivider)\b[^)]*?)\)', r'Text(\1)', code)

# Remove 'const' before TextStyle when textMain or textSub or iconColor is used
code = re.sub(r'const\s+TextStyle\(([^)]*?\b(?:textMain|textSub|iconColor|borderDivider)\b[^)]*?)\)', r'TextStyle(\1)', code)

# Remove 'const' from parent widgets that enclose dynamic color expressions
# e.g., const Text('• 1st', style: TextStyle(color: textSub, fontSize: 12))
code = re.sub(r'const\s+Text\(([^,)]*?,\s*style:\s*TextStyle\([^)]*?\b(?:textMain|textSub|iconColor|borderDivider)\b[^)]*?\))\)', r'Text(\1)', code)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)

print("Successfully updated theme getters and removed invalid const expressions in home_feed_screen.dart")
