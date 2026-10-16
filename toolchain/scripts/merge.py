#!/usr/bin/env python3
"""
Merge tar.xz archives created by tar.py.

Paths that appear in more than one input must have identical entries.
"""

import heapq
import io
import os
import sys
import tarfile

def entries(index, path):
    """Yield (name, index, member, data) for each member of a sorted archive"""
    with tarfile.open(path, 'r|xz') as tar:
        previous = None
        for member in tar:
            assert previous is None or previous < member.name, f"{path} is not sorted at {member.name}"
            previous = member.name
            data = tar.extractfile(member).read() if member.isreg() else None
            yield member.name, index, member, data

def same(a, b):
    return (a.type, a.mode, a.linkname) == (b.type, b.mode, b.linkname)

def merge(output_file, input_files):
    merged = heapq.merge(*(entries(i, path) for i, path in enumerate(input_files)))

    conflicts = []
    with tarfile.open(output_file, 'w:xz') as out:
        last = None
        for name, index, member, data in merged:
            if last is not None and last[0] == name:
                if not (same(last[2], member) and last[3] == data):
                    conflicts.append(f"{name} differs between {input_files[last[1]]} and {input_files[index]}")
                continue
            out.addfile(member, io.BytesIO(data) if data is not None else None)
            last = (name, index, member, data)

    if conflicts:
        os.remove(output_file)
        for conflict in conflicts:
            print(f"error: {conflict}", file=sys.stderr)
        sys.exit(1)

def main():
    if len(sys.argv) < 3:
        print("Usage: python merge.py <output.tar.xz> <input1.tar.xz> [input2.tar.xz] ...")
        sys.exit(1)

    merge(sys.argv[1], sys.argv[2:])
    print(f"Created {sys.argv[1]}")

if __name__ == "__main__":
    main()
