#!/usr/bin/env python3
"""
Replace memory.loadN/storeN calls with typed pointer dereference.

Replaces:
  memory.load8(ptr)      -> { var _p: *u8 = ptr; *_p }
  memory.store8(ptr, v)  -> { var _p: *u8 = ptr; *_p = v }
  memory.load32(ptr)     -> { var _p: *uint = ptr; *_p }
  memory.store32(ptr, v) -> { var _p: *uint = ptr; *_p = v }
  memory.load64(ptr)     -> { var _p: *ptr = ptr; *_p }
  memory.store64(ptr, v) -> { var _p: *ptr = ptr; *_p = v }

Usage: python3 scripts/replace_load_store.py [--dry-run] [file ...]
If no files given, processes all .cute files under pkg/.
"""

import re
import sys
import os
import glob as globmod

# Type mapping for load/store widths
TYPE_MAP = {
    '8': 'u8',
    '16': 'u16',  # not used currently but included for completeness
    '32': 'uint',
    '64': 'ptr',
}

_counter = 0

def unique_var():
    global _counter
    _counter += 1
    return f"_p{_counter}"

def replace_line(line):
    """Replace memory.load*/store* calls in a single line.
    
    Returns (new_line, needs_pre_decl list).
    Each pre_decl is a string like "    var _p1: *u8 = <expr>"
    """
    needs_pre_decl = []
    
    # Pattern for memory.storeN(expr, val)
    # We need to handle nested expressions, so use a bracket-aware approach
    store_pattern = re.compile(r'memory\.store(\d+)\(')
    load_pattern = re.compile(r'memory\.load(\d+)\(')
    
    # Process stores first (they have assignment semantics)
    result = line
    while store_pattern.search(result):
        m = store_pattern.search(result)
        width = m.group(1)
        elem_type = TYPE_MAP.get(width)
        if not elem_type:
            break
        
        # Find matching closing paren
        start = m.start()
        paren_start = m.end() - 1  # position of '('
        depth = 1
        i = paren_start + 1
        while i < len(result) and depth > 0:
            if result[i] == '(':
                depth += 1
            elif result[i] == ')':
                depth -= 1
            i += 1
        if depth != 0:
            break  # malformed, skip
        
        paren_end = i - 1  # position of matching ')'
        args_str = result[paren_start+1:paren_end]
        
        # Split args (only top-level comma)
        args = []
        d = 0
        current = ''
        for ch in args_str:
            if ch == '(':
                d += 1
            elif ch == ')':
                d -= 1
            elif ch == ',' and d == 0:
                args.append(current.strip())
                current = ''
                continue
            current += ch
        args.append(current.strip())
        
        if len(args) != 2:
            break  # unexpected, skip
        
        ptr_expr = args[0]
        val_expr = args[1]
        
        var_name = unique_var()
        pre_decl = f"var {var_name}: *{elem_type} = {ptr_expr}"
        # store 需要 unsafe.cast 确保类型匹配（原 store 隐式截断/转换）
        if width == '8':
            replacement = f"*{var_name} = unsafe.cast[u8]({val_expr})"
        elif width == '32':
            replacement = f"*{var_name} = unsafe.cast[uint]({val_expr})"
        elif width == '64':
            replacement = f"*{var_name} = unsafe.cast[ptr]({val_expr})"
        else:
            replacement = f"*{var_name} = {val_expr}"
        
        # Replace in result
        result = result[:start] + replacement + result[paren_end+1:]
        needs_pre_decl.append(pre_decl)
    
    # Process loads
    while load_pattern.search(result):
        m = load_pattern.search(result)
        width = m.group(1)
        elem_type = TYPE_MAP.get(width)
        if not elem_type:
            break
        
        start = m.start()
        paren_start = m.end() - 1
        depth = 1
        i = paren_start + 1
        while i < len(result) and depth > 0:
            if result[i] == '(':
                depth += 1
            elif result[i] == ')':
                depth -= 1
            i += 1
        if depth != 0:
            break
        
        paren_end = i - 1
        ptr_expr = result[paren_start+1:paren_end].strip()
        
        var_name = unique_var()
        pre_decl = f"var {var_name}: *{elem_type} = {ptr_expr}"
        replacement = f"*{var_name}"
        
        result = result[:start] + replacement + result[paren_end+1:]
        needs_pre_decl.append(pre_decl)
    
    return result, needs_pre_decl

def process_file(filepath, dry_run=False):
    """Process a single .cute file."""
    global _counter
    _counter = 0  # Reset per file
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Check if file has any memory.load/store calls
    has_calls = any('memory.store' in l or 'memory.load' in l for l in lines)
    if not has_calls:
        return 0
    
    new_lines = []
    replacements = 0
    
    for line in lines:
        if 'memory.store' not in line and 'memory.load' not in line:
            new_lines.append(line)
            continue
        
        # Get indentation
        stripped = line.lstrip()
        indent = line[:len(line) - len(stripped)]
        
        new_line, pre_decls = replace_line(stripped)
        
        if pre_decls:
            replacements += len(pre_decls)
            for decl in pre_decls:
                new_lines.append(f"{indent}{decl}\n")
            new_lines.append(f"{indent}{new_line}")
        else:
            new_lines.append(f"{indent}{new_line}")
    
    if replacements > 0 and not dry_run:
        with open(filepath, 'w') as f:
            f.writelines(new_lines)
    
    return replacements

def main():
    dry_run = '--dry-run' in sys.argv
    files = [a for a in sys.argv[1:] if a != '--dry-run']
    
    if not files:
        # Find all .cute files under pkg/
        base = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'pkg')
        for root, dirs, fnames in os.walk(base):
            for fname in fnames:
                if fname.endswith('.cute'):
                    files.append(os.path.join(root, fname))
        files.sort()
    
    total = 0
    for f in files:
        count = process_file(f, dry_run)
        if count > 0:
            print(f"{'[DRY] ' if dry_run else ''}{f}: {count} replacements")
            total += count
    
    print(f"\n{'[DRY] ' if dry_run else ''}Total: {total} replacements across {len(files)} files")

if __name__ == '__main__':
    main()
