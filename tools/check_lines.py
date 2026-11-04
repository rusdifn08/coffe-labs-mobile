import os

def main():
    root = os.path.join(os.path.dirname(__file__), '..', 'lib')
    files = []
    for r, d, fs in os.walk(root):
        for f in fs:
            if f.endswith('.dart'):
                p = os.path.join(r, f)
                with open(p, 'r', encoding='utf-8', errors='ignore') as fp:
                    lines = len(fp.readlines())
                files.append((lines, os.path.relpath(p, os.path.join(root, '..'))))
    
    files.sort(reverse=True)
    print(f"Total dart files: {len(files)}")
    print(f"Files > 450 lines: {len([f for f in files if f[0] > 450])}")
    print(f"Files > 500 lines: {len([f for f in files if f[0] > 500])}")
    print(f"Files > 1000 lines: {len([f for f in files if f[0] > 1000])}")
    print("\n--- Files > 450 lines ---")
    for lines, path in files:
        if lines > 450:
            print(f"{lines:5d}  {path}")

if __name__ == '__main__':
    main()
