#!/usr/bin/env python3
import sys
from pathlib import Path
import re
from collections import defaultdict

RE_RES = re.compile(r'["\'](res://[^"\']+)["\']')
RE_PRELOAD = re.compile(r'preload\(["\'](res://[^"\']+)["\']\)')
RE_LOAD = re.compile(r'load\(["\'](res://[^"\']+)["\']\)')
RE_RL = re.compile(r'ResourceLoader\.load\(["\'](res://[^"\']+)["\']\)')

TEXT = {'.gd', '.tscn', '.tres', '.res'}

def extract_refs(text):
    out = set()
    for regex in (RE_RES, RE_PRELOAD, RE_LOAD, RE_RL):
        for r in regex.findall(text):
            out.add(r)
    return out

def top_level(folder):
    f = folder.strip("/")
    if not f:
        return ""
    return f.split("/")[0]

def main():
    if len(sys.argv) < 3:
        print("usage: python folder_depmap.py /path/to/project output.dot")
        sys.exit(1)

    root = Path(sys.argv[1]).resolve()
    out_file = Path(sys.argv[2]).resolve()
    addons = root / "addons"

    if not addons.exists():
        print("addons folder not found")
        sys.exit(1)

    folder_deps = defaultdict(set)

    for p in addons.rglob("*"):
        if not p.is_file(): 
            continue
        if p.suffix.lower() not in TEXT: 
            continue

        try:
            text = p.read_text(encoding="utf8", errors="ignore")
        except:
            continue

        refs = extract_refs(text)

        src_folder = "/" + str(p.parent.relative_to(addons)).replace("\\", "/")
        if src_folder == "/.": 
            src_folder = "/"

        for r in refs:
            if not r.startswith("res://addons/"):
                continue

            rel = r.replace("res://addons/", "")
            parts = rel.split("/")
            if len(parts) == 0:
                continue

            dst_folder = "/" + "/".join(parts[:-1]) if len(parts) > 1 else "/" + parts[0]

            src_top = top_level(src_folder)
            dst_top = top_level(dst_folder)

            if src_top == dst_top or dst_top == "%s":
                continue
            print(src_top + " depends on " + dst_top)

            folder_deps[src_folder].add(dst_folder)

    lines = []
    lines.append("digraph FOLDER_DEPS {")
    lines.append("  rankdir=LR;")
    lines.append("  node [shape=box, fontsize=10];")
    lines.append("  node [style=filled, fillcolor=black, fontcolor=white, color=black]")
    lines.append("  edge [color=white, fontcolor=white, penwidth=2]")

    all_folders = set(folder_deps.keys())
    for deps in folder_deps.values():
        if deps == "/%s": continue
        all_folders.update(deps)

    for f in sorted(all_folders):
        label = f if f != "/" else "root"
        lines.append(f'  "{f}" [label="{label}"];')

    for src, targets in folder_deps.items():
        for dst in targets:
            if src != dst:
                lines.append(f'  "{src}" -> "{dst}";')

    lines.append("}")

    out_file.write_text("\n".join(lines), encoding="utf8")
    print(f"written: {out_file}")

if __name__ == "__main__":
    main()

