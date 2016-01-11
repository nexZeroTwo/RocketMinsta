#!/usr/bin/env python3

import os
import hashlib

from pathlib import Path


def hash_file(filepath):
    sha = hashlib.sha1()
    with open(filepath, 'rb') as f:
        while True:
            block = f.read(2**10)
            if not block:
                break
            sha.update(block)
        return sha.hexdigest()


def duplicates(dir):
    dups = {}

    for dirname, subdirs, files in os.walk(dir):
        for filename in files:
            path = os.path.join(dirname, filename)
            fhash = hash_file(path)

            if os.path.islink(path):
                continue

            if fhash in dups:
                dups[fhash].append(path)
            else:
                dups[fhash] = [path]

    for k, v in tuple(dups.items()):
        if len(v) < 2:
            del dups[k]

    return dups


def link(src, dst):
    log("Creating symlink: %s -> %s", src, dst)
    os.symlink(src, dst)


def remove(dst):
    log("Removing: %s", dst)
    os.remove(dst)


def optimize(path):
    path = str(path)
    log("Processing %s", path)

    for fhash, dups in duplicates(path).items():
        log("%i duplicates: %s", len(dups), ', '.join(s[len(path)+1:] for s in dups))
        base, *dups = dups

        for dup in dups:
            relpath = str(Path(base).relative_to(os.path.commonpath((base, dup))))
            remove(dup)
            link(relpath, dup)


def main():
    rm = Path(__file__).absolute().parent.parent.parent
    tuple(map(optimize, rm.glob('*.pk3dir')))


def log(fmt, *args):
    print(fmt % args)


if __name__ == '__main__':
    main()
