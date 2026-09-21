#!/usr/bin/env python3
"""
Post-process: add unsafe.cast for store assignments where pointer type doesn't match value type.
Specifically: if `var _pN: *u8 = addr` and `*_pN = val`, wrap val with unsafe.cast[u8]().

Usage: python3 scripts/fix_store_types.py [--dry-run] [file ...]
"""

import re
import sys
import os

def process_file(filepath, dry_run=False):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Find all var _pN: *Type = ... declarations
    ptr_types = {}  # var_name -> elem_type
    for line in lines:
        m = re.match(r'\s*var\s+(_p\d+):\s*\*(\w+)\s*=', line)
        if m:
            ptr_types[m.group(1)] = m.group(2)
    
    new_lines = []
    fixes = 0
    
    for line in lines:
        # Match: *_pN = val  (where val is NOT already wrapped in unsafe.cast)
        m = re.match(r'(\s*\*)(_p\d+)(\s*=\s*)(.+)', line.rstrip())
        if m:
            var_name = m.group(2)
            indent = line[:len(line) - len(line.lstrip())]
            val = m.group(4).strip()
            
            if var_name in ptr_types and not val.startswith('unsafe.cast'):
                elem_type = ptr_types[var_name]
                # Only cast if value isn't already the right type
                # Simple heuristic: wrap all store values with unsafe.cast
                new_lines.append(f"{indent}*{var_name} = unsafe.cast[{elem_type}]({val})\n")
                fixes += 1
                continue
        
        new_lines.append(line)
    
    if fixes > 0 and not dry_run:
        with open(filepath, 'w') as f:
            f.writelines(new_lines)
    
    return fixes

def main():
    dry_run = '--dry-run' in sys.argv
    files = [a for a in sys.argv[1:] if a != '--dry-run']
    
    if not files:
        base = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'pkg')
        for root, dirs, fnames in os.walk(base):
            for fname in fnames:
                if fname.endswith('.cute'):
                    files.append(os.path.join(root, fname))
        # Also include test/
        base_test = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'test')
        for root, dirs, fnames in os.walk(base_test):
            for fname in fnames:
                if fname.endswith('.cute'):
                    files.append(os.path.join(root, fname))
        files.sort()
    
    total = 0
    for f in files:
        count = process_file(f, dry_run)
        if count > 0:
            print(f"{'[DRY] ' if dry_run else ''}{f}: {count} fixes")
            total += count
    
    print(f"\n{'[DRY] ' if dry_run else ''}Total: {total} fixes across {len(files)} files")

if __name__ == '__main__':
    main()
