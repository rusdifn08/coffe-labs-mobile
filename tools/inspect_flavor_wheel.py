with open('lib/screens/flavor_wheel_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(0, 400):
    l = lines[i]
    if any(k in l for k in ['List<', 'Map<', 'final ', 'static const', 'class ']):
        print(f"{i+1:4d}: {l.strip()[:80]}")
