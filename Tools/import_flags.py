#!/usr/bin/env python3
"""Builds the asset catalogs from the two flag sets this package draws.

    python3 Tools/import_flags.py --circle <unpacked circle-flags release> --square <unpacked square-flags release>

Either can be given alone. Each set is the asset catalog of its own target, `CircleFlagArtwork` and
`SquareFlagArtwork`, rebuilt from scratch together with the Swift file that lists the codes it has
a flag for. Give the release's version with --circle-version and --square-version to have it
recorded in that file.

Only the flags of ISO 3166-1 alpha-2 are taken, the 249 codes the standard assigns to countries and
territories, and one beside them: "eu", the European Union's, which the euro goes by. The sets
draw more: other two-letter codes, states, languages, organizations.

What is changed in each SVG, and why:

- circle-flags is left as it is drawn, cut to a circle by its mask. An asset catalog draws that
  mask correctly, which the contact sheet "circleArtworkUncut" shows: the flags are round there
  without the view cutting them.
- square-flags colours its shapes through CSS variables, `var(--flag-palette-navy, #002266)`, which
  an asset catalog doesn't know. Each is replaced by the colour it falls back to.
- Both say a flag is 512 points wide. An asset catalog keeps a bitmap at three times the declared
  size for each, megabytes for a whole set, beside the vector. They are declared at 16 points: the
  smallest at which Xcode's view of the catalog still shows what a flag is. Shown larger, a flag
  is drawn from its vector, sharp at each size. Measured for the circles on one device, with the
  263 flags there were then: 1536-pixel bitmaps 4.8 MB, 40-point ones 753 KB, 16-point ones 522 KB,
  1-point ones 348 KB.
"""

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
# In points. Small on purpose, see above: larger flags are drawn from the vector. Another can be
# given with --declared-size, to compare how long drawing takes (see DrawingTimeTests).
DECLARED_SIZE = 16
# The codes ISO 3166-1 alpha-2 assigns
ISO_3166_1 = """
ad ae af ag ai al am ao aq ar as at au aw ax az
ba bb bd be bf bg bh bi bj bl bm bn bo bq br bs bt bv bw by bz
ca cc cd cf cg ch ci ck cl cm cn co cr cu cv cw cx cy cz
de dj dk dm do dz
ec ee eg eh er es et
fi fj fk fm fo fr
ga gb gd ge gf gg gh gi gl gm gn gp gq gr gs gt gu gw gy
hk hm hn hr ht hu
id ie il im in io iq ir is it
je jm jo jp
ke kg kh ki km kn kp kr kw ky kz
la lb lc li lk lr ls lt lu lv ly
ma mc md me mf mg mh mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz
na nc ne nf ng ni nl no np nr nu nz
om
pa pe pf pg ph pk pl pm pn pr ps pt pw py
qa
re ro rs ru rw
sa sb sc sd se sg sh si sj sk sl sm sn so sr ss st sv sx sy sz
tc td tf tg th tj tk tl tm tn to tr tt tv tw tz
ua ug um us uy uz
va vc ve vg vi vn vu
wf ws
ye yt
za zm zw
""".split()
assert len(set(ISO_3166_1)) == 249

# Beside the standard: the European Union, for the euro
ALSO = ["eu"]

CIRCLE_MASK = '<mask id="a"><circle cx="256" cy="256" r="256" fill="#fff"/></mask>'
CIRCLE_MASKED_GROUP = '<g mask="url(#a)">'
CSS_VARIABLE = re.compile(r"var\(\s*--[\w-]+\s*,\s*(#[0-9a-fA-F]{3,8})\s*\)")
SVG_TAG = re.compile(r"<svg\b[^>]*>")


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def resized(svg):
    """The SVG declared at `DECLARED_SIZE`, drawing the same 512 by 512 picture."""
    tag = SVG_TAG.search(svg)
    if tag is None or 'width="512"' not in tag.group(0) or 'height="512"' not in tag.group(0):
        return None
    new_tag = tag.group(0).replace('width="512"', f'width="{DECLARED_SIZE}"').replace('height="512"', f'height="{DECLARED_SIZE}"')
    if "viewBox=" not in new_tag:
        new_tag = new_tag[:-1] + ' viewBox="0 0 512 512">'
    elif 'viewBox="0 0 512 512"' not in new_tag:
        return None
    return svg[:tag.start()] + new_tag + svg[tag.end():]


def circle(svg):
    # Drawn the way the others are, cut to a circle by the set's mask, or left out and reported
    if CIRCLE_MASK not in svg or CIRCLE_MASKED_GROUP not in svg:
        return None
    return resized(svg)


def square(svg):
    svg = CSS_VARIABLE.sub(lambda match: match.group(1), svg)
    if "var(" in svg:
        return None
    return resized(svg)


def import_set(source, name, version, convert):
    """Imports one set as the asset catalog of the target `<name>FlagArtwork`."""
    flags = Path(source) / "flags"
    if not flags.is_dir():
        sys.exit(f"No flags folder in {source}")

    target = ROOT / "Sources" / f"{name}FlagArtwork"
    catalog = target / "Resources" / "Flags.xcassets"
    if catalog.exists():
        shutil.rmtree(catalog)
    catalog.mkdir(parents=True)
    write_json(catalog / "Contents.json", {"info": {"author": "xcode", "version": 1}})

    codes, skipped = [], []
    for code in sorted(ISO_3166_1 + ALSO):
        file = flags / f"{code}.svg"
        if not file.exists():
            skipped.append(code)
            continue
        # Some codes are links to another flag's file, as "eu" is to european_union.svg. They
        # only count within the flags folder: a release is unpacked from the internet.
        resolved = file.resolve()
        if not resolved.is_relative_to(flags.resolve()) or not resolved.is_file():
            skipped.append(code)
            continue
        svg = convert(resolved.read_text(encoding="utf-8"))
        if svg is None:
            skipped.append(code)
            continue

        image_set = catalog / f"{code}.imageset"
        image_set.mkdir()
        (image_set / f"{code}.svg").write_text(svg, encoding="utf-8")
        write_json(image_set / "Contents.json", {
            "images": [{"filename": f"{code}.svg", "idiom": "universal"}],
            "info": {"author": "xcode", "version": 1},
            "properties": {"preserves-vector-representation": True},
        })
        codes.append(code)

    lower = name.lower()
    rows = "\n".join("    " + ", ".join(f'"{code}"' for code in codes[i:i + 12]) + "," for i in range(0, len(codes), 12))
    (target / f"{name}FlagCodes.swift").write_text(f'''// Written by Tools/import_flags.py. Don't edit: run it again instead.

/// The release of {lower}-flags the artwork is from
let {lower}FlagsVersion = "{version}"

/// The lowercase codes there is a flag for
let {lower}FlagCodes: Set<String> = [
{rows}
]
''')

    print(f"{name}: {len(codes)} flags")
    if skipped:
        print(f"{name}: WITHOUT A FLAG, as the set has none or draws it another way: " + ", ".join(skipped))


def main():
    global DECLARED_SIZE
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--circle", help="an unpacked circle-flags release")
    parser.add_argument("--circle-version", default="unknown")
    parser.add_argument("--square", help="an unpacked square-flags release")
    parser.add_argument("--square-version", default="unknown")
    parser.add_argument("--declared-size", type=int, default=DECLARED_SIZE, help="in points; leave it out for a release")
    arguments = parser.parse_args()
    if not arguments.circle and not arguments.square:
        parser.error("give --circle, --square or both")

    DECLARED_SIZE = arguments.declared_size

    if arguments.circle:
        import_set(arguments.circle, "Circle", arguments.circle_version, circle)
    if arguments.square:
        import_set(arguments.square, "Square", arguments.square_version, square)


if __name__ == "__main__":
    main()
