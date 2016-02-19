
from gimpfu import *
from gimp import *

import itertools
import numpy as np

tfile = "extras/gfx/ring_template.xcf"
targ = "gfx.pk3dir/gfx/hud/ring%i.tga"

tmpl = pdb.gimp_file_load(tfile, tfile)
img = tmpl.duplicate()

size = np.array([tmpl.width, tmpl.height])
center = size * 0.5
m = 7

for segs in range(2, 25):
    img = tmpl.duplicate()

    for s in range(segs):
        a = (0.25 + 2 * s / float(segs)) * np.pi 

        v = np.array([np.cos(a),  np.sin(a)])
        p = np.array([v[1], -v[0]])
        l = size[0]

        o1 = center + p * m
        o2 = center - p * m
        r1 = o1 + v * l
        r2 = o2 + v * l

        poly = [list(o) for o in [o1, o2, r2, r1]]
        poly = list(itertools.chain(*poly))

        pdb.gimp_image_select_polygon(img, CHANNEL_OP_ADD if s else CHANNEL_OP_REPLACE, len(poly), poly)

    pdb.gimp_edit_clear(img.layers[0])

    fname = targ % segs
    pdb.gimp_file_save(img, pdb.gimp_image_merge_visible_layers(img, 1), fname, fname)
    pdb.gimp_image_delete(img)

fname = targ % 1
pdb.gimp_file_save(tmpl, pdb.gimp_image_merge_visible_layers(tmpl, 1), fname, fname)
pdb.gimp_image_delete(tmpl)
pdb.gimp_quit(1)
