with open('lib/screens/brew_timer_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

target = "return ':';"
replacement = "return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';"

if target in c:
    c = c.replace(target, replacement)
    with open('lib/screens/brew_timer_screen.dart', 'w', encoding='utf-8') as f:
        f.write(c)
    print("Fixed!")
else:
    print("Target not found!")
