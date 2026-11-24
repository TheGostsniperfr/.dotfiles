"""Generate a minimal Plasma style: rounded translucent panel and rounded task
highlights. Everything else falls back to Breeze. Colors come from the active
color scheme through Plasma's ColorScheme-* classes.

usage: plasma-style.py <out-dir> <id> <name> <panel-radius> <panel-alpha> <task-radius>
"""

import json
import os
import sys

out, style_id, name = sys.argv[1], sys.argv[2], sys.argv[3]
panel_r = int(sys.argv[4])
panel_alpha = float(sys.argv[5])
task_r = int(sys.argv[6])

STYLE = """<style id="current-color-scheme" type="text/css">
.ColorScheme-Text { color:#232629; }
.ColorScheme-Background { color:#eff0f1; }
.ColorScheme-Highlight { color:#3daee9; }
.ColorScheme-NegativeText { color:#da4453; }
.ColorScheme-PositiveText { color:#27ae60; }
</style>"""


def frame(prefix, x0, y0, r, fill_cls, fill_op, edge=None, edge_cls=None, edge_w=2):
    """9-slice rounded frame: r x r corners, 1px stretched edges, 1x1 center.
    `edge` draws an accent bar on the stretched tile of that side only, so it
    stays centered and shorter than the highlight, like a pill indicator."""
    p = f"{prefix}-" if prefix else ""
    s = 1
    X, Y = x0, y0

    def fill(d, cls=fill_cls, op=fill_op):
        return f'<path class="{cls}" fill="currentColor" fill-opacity="{op}" d="{d}"/>'

    def rect(x, y, w, h):
        return f"M{x},{y}h{w}v{h}h{-w}Z"

    def corner(cx, cy, sx, sy):
        ox, oy = cx + sx * r, cy + sy * r
        sweep = 1 if sx * sy > 0 else 0
        return f"M{cx},{cy} L{ox},{cy} A{r},{r} 0 0 {sweep} {cx},{oy} Z"

    tiles = {
        "topleft": (X, Y, r, r, corner(X + r, Y + r, -1, -1)),
        "topright": (X + r + s, Y, r, r, corner(X + r + s, Y + r, 1, -1)),
        "bottomleft": (X, Y + r + s, r, r, corner(X + r, Y + r + s, -1, 1)),
        "bottomright": (X + r + s, Y + r + s, r, r, corner(X + r + s, Y + r + s, 1, 1)),
        "top": (X + r, Y, s, r, rect(X + r, Y, s, r)),
        "bottom": (X + r, Y + r + s, s, r, rect(X + r, Y + r + s, s, r)),
        "left": (X, Y + r, r, s, rect(X, Y + r, r, s)),
        "right": (X + r + s, Y + r, r, s, rect(X + r + s, Y + r, r, s)),
        "center": (X + r, Y + r, s, s, rect(X + r, Y + r, s, s)),
    }
    bars = {
        "bottom": rect(X + r, Y + 2 * r + s - edge_w, s, edge_w),
        "top": rect(X + r, Y, s, edge_w),
        "left": rect(X, Y + r, edge_w, s),
        "right": rect(X + 2 * r + s - edge_w, Y + r, edge_w, s),
    }
    parts = []
    for name, (x, y, w, h, d) in tiles.items():
        body = fill(d)
        if name == edge:
            body += fill(bars[edge], edge_cls, 1)
        parts.append(f'<g id="{p}{name}"><rect x="{x}" y="{y}" width="{w}" height="{h}" fill="none"/>{body}</g>')
    return parts, 2 * r + s


def hints(prefix, x0, y0, margins):
    p = f"{prefix}-" if prefix else ""
    out = []
    for side, size in margins.items():
        w, h = (size, 1) if side in ("left", "right") else (1, size)
        out.append(f'<rect id="{p}hint-{side}-margin" x="{x0}" y="{y0}" width="{w}" height="{h}" fill="none"/>')
    return out


def svg(elements, w, h):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 {w} {h}" width="{w}" height="{h}">'
        + STYLE + "".join(elements) + "</svg>\n"
    )


def tasks():
    els, x = [], 0
    states = {
        # state: (fill class, fill opacity, accent?)
        "normal": ("ColorScheme-Text", 0.07, False),
        "minimized": ("ColorScheme-Text", 0.04, False),
        "hover": ("ColorScheme-Text", 0.12, False),
        "focus": ("ColorScheme-Text", 0.14, True),
        "attention": ("ColorScheme-NegativeText", 0.22, True),
        "progress": ("ColorScheme-PositiveText", 0.28, False),
    }
    orient = {"": "bottom", "north": "top", "west": "left", "east": "right"}
    for o, edge in orient.items():
        for state, (cls, op, accent) in states.items():
            prefix = f"{o}-{state}" if o else state
            parts, W = frame(
                prefix, x, 0, task_r, cls, op,
                edge=edge if accent else None,
                edge_cls="ColorScheme-Highlight" if state == "focus" else "ColorScheme-NegativeText",
                edge_w=3,
            )
            els += parts
            if state == "normal":
                els += hints(prefix, x, 2 * task_r + 4, {"top": 2, "bottom": 2, "left": 2, "right": 2})
            x += W + 4
    return svg(els, x, 2 * task_r + 12)


def panel(alpha):
    parts, W = frame("", 0, 0, panel_r, "ColorScheme-Background", alpha)
    mask, _ = frame("mask", W + 4, 0, panel_r, "ColorScheme-Background", 1)
    m = max(4, panel_r // 2)
    h = hints("", 0, 2 * panel_r + 4, {"top": m, "bottom": m, "left": m + 2, "right": m + 2})
    return svg(parts + mask + h, 2 * W + 8, 2 * panel_r + 12)


def write(rel, content):
    path = os.path.join(out, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content)


write("widgets/tasks.svg", tasks())
write("widgets/panel-background.svg", panel(panel_alpha))
write("translucent/widgets/panel-background.svg", panel(panel_alpha))
write("opaque/widgets/panel-background.svg", panel(1.0))
write("solid/widgets/panel-background.svg", panel(1.0))
write("plasmarc", "[ContrastEffect]\nenabled=false\n[AdaptiveTransparency]\nenabled=true\n")
write(
    "metadata.json",
    json.dumps(
        {
            "KPlugin": {
                "Id": style_id,
                "Name": name,
                "Description": "Rounded translucent panel and task highlights, Breeze for the rest",
                "License": "MIT",
                "Version": "1",
                "Authors": [{"Name": "dotfiles"}],
                "EnabledByDefault": True,
            },
            "X-Plasma-API": "5.0",
            "X-Plasma-Fallback-Theme": "default",
        },
        indent=2,
    ),
)
