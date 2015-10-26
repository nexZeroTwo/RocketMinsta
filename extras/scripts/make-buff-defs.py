#!/usr/bin/env python3

import sys, os, re, collections
from pathlib import Path

Buff = collections.namedtuple('Buff', ['name', 'fullname', 'color'])
buffdefRegex = re.compile(r'\s*BUFFDEF\s*\(BUFF_[A-Z]+\s*,\s*([a-z]+),\s*"([a-zA-Z\s]*)",\s*\'((\s*[0-9]+\.[0-9]+){3})\'\)\s*\\\s*')
buffs = []

def makeBuffDef(buff, team):
    return """
/*QUAKED item_buff_%s%s (%s) (-16 -16 -16) (16 16 16)
The %s Buff%s
*/""" % (
            buff.name,
            ("_team%i" % team) if team else "",
            " ".join([str(f) for f in buff.color]),
            buff.fullname,
            (" (%s Team)" % (["Red", "Blue", "Yellow", "Pink"][team-1])) if team else "",
        )

def makeBuffDefs(buff):
    return "\n".join([makeBuffDef(buff, team) for team in range(5)])


with (Path(sys.argv[0]).parent.parent.parent / "qcsrc/common/buffs.qh").open() as defsfile:
    for line in defsfile:
        matches = buffdefRegex.findall(line)

        if matches:
            name, fullname, color, _ = matches[0]
            color = [float(a) for a in color.strip().split(' ') if a]
            print(makeBuffDefs(Buff(name, fullname, color)) + "\n")
