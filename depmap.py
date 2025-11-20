#!/usr/bin/env python3
import sys
from pathlib import Path
import re
from collections import defaultdict

# resource references
RE_RES = re.compile(r'["\'](res://[^"\']+)["\']')
RE_PRELOAD = re.compile(r'preload\(["\'](res://[^"\']+)["\']\)')
RE_LOAD = re.compile(r'load\(["\'](res://[^"\']+)["\']\)')
RE_RL = re.compile(r'ResourceLoader\.load\(["\'](res://[^"\']+)["\']\)')

# gdscript class features
RE_CLASS_NAME = re.compile(r'^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)', re.MULTILINE)
RE_CLASS_USAGE = re.compile(
    r'\b([A-Za-z_][A-Za-z0-9_]*)\s*(?:\.new\(|:|->|as\b)',
    re.MULTILINE
)

TEXT = {'.gd', '.tscn', '.tres', '.res'}

def extract_refs_basic(text):
    out = set()
    for r in RE_RES.findall(text): out.add(r)
    for r in RE_PRELOAD.findall(text): out.add(r)
    for r in RE_LOAD.findall(text): out.add(r)
    for r in RE_RL.findall(text): out.add(r)
    return out

def extract_gdscript_classes(text):
    return set(RE_CLASS_NAME.findall(text))

def extract_gdscript_class_usages(text):
    return set(RE_CLASS_USAGE.findall(text))

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

    class_map = {}

    for p in addons.rglob("*.gd"):
        try:
            text = p.read_text(encoding="utf8", errors="ignore")
        except:
            continue
        classes = extract_gdscript_classes(text)
        if not classes:
            continue
        res_path = "res://" + str(p.relative_to(root)).replace("\\", "/")
        for cls in classes:
            class_map[cls] = res_path

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

        src_folder = "/" + str(p.parent.relative_to(addons)).replace("\\", "/")
        if src_folder == "/.":
            src_folder = "/"

        refs = extract_refs_basic(text)

        if p.suffix.lower() == ".gd":
            used_classes = extract_gdscript_class_usages(text)
            for cls in used_classes:
                if cls in class_map:
                    refs.add(class_map[cls])

        for r in refs:
            if not r.startswith("res://addons/"):
                continue

            rel = r.replace("res://addons/", "")
            parts = rel.split("/")

            if len(parts) >= 2:
                dst_folder = "/" + parts[0]
            else:
                dst_folder = "/" + parts[0]

            src_top = top_level(src_folder)
            dst_top = top_level(dst_folder)

            if src_top == dst_top or dst_top == "%s":
                continue

            folder_deps[src_folder].add(dst_folder)

    lines = []
    lines.append("digraph FOLDER_DEPS {")
    lines.append("  rankdir=LR;")
    lines.append("  node [shape=box, fontsize=10, style=filled, fillcolor=black, fontcolor=white, color=black];")
    lines.append("  edge [color=white, penwidth=2];")

    all_folders = set(folder_deps.keys())
    for deps in folder_deps.values():
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

