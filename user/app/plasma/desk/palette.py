"""Generate the KDE color scheme for a desk combo.

Raw base16 mappings put mid-tone accents (sky blues, teals, yellows) on the
background as-is, which is unreadable on light palettes. Every color drawn as
text is pushed toward the foreground until it reaches WCAG contrast 4.5:1.

usage: palette.py <palette.json> <out-dir>
palette.json: {"id", "name", "polarity", "accent", "colors": {"base00": "rrggbb", ...}}
"""

import json
import os
import sys

TEXT_CONTRAST = 4.5
SOFT_CONTRAST = 3.0  # inactive text, comments


def rgb(hex_):
    return tuple(int(hex_[i : i + 2], 16) for i in (0, 2, 4))


def luminance(c):
    def chan(v):
        v /= 255
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4

    r, g, b = (chan(v) for v in c)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def readable(color, bg, toward, target):
    """Blend color toward `toward` in small steps until it reaches target."""
    t = 0.0
    out = color
    while contrast(out, bg) < target and t < 1.0:
        t += 0.04
        out = mix(color, toward, t)
    return out


def triple(c):
    return ",".join(str(v) for v in c)


def ini(sections):
    lines = []
    for name, entries in sections.items():
        lines.append(f"[{name}]")
        lines += [f"{k}={v}" for k, v in entries.items()]
        lines.append("")
    return "\n".join(lines)


def main():
    spec = json.load(open(sys.argv[1]))
    out = sys.argv[2]
    os.makedirs(out, exist_ok=True)
    c = {k: rgb(v) for k, v in spec["colors"].items()}
    bg, fg = c["base00"], c["base05"]
    alt = c["base01"]
    accent = readable(c[spec["accent"]], bg, fg, TEXT_CONTRAST)

    def text(slot, target=TEXT_CONTRAST, on=bg):
        return readable(c[slot], on, fg, target)

    # Selection: accent background, whichever of bg/fg reads better on it.
    sel_bg = c[spec["accent"]]
    sel_fg = max((bg, fg), key=lambda x: contrast(x, sel_bg))

    def kde_set(back, back_alt, fore):
        return {
            "BackgroundNormal": triple(back),
            "BackgroundAlternate": triple(back_alt),
            "ForegroundNormal": triple(fore),
            "ForegroundActive": triple(accent),
            "ForegroundInactive": triple(readable(c["base04"], back, fore, SOFT_CONTRAST + 1)),
            "ForegroundLink": triple(accent),
            "ForegroundVisited": triple(text("base0E")),
            "ForegroundNegative": triple(text("base08")),
            "ForegroundNeutral": triple(text("base09")),
            "ForegroundPositive": triple(text("base0B")),
            "DecorationFocus": triple(c[spec["accent"]]),
            "DecorationHover": triple(c[spec["accent"]]),
        }

    kde = {
        "General": {"ColorScheme": spec["id"], "Name": spec["name"]},
        "KDE": {"contrast": 4},
        "Colors:Window": kde_set(bg, alt, fg),
        "Colors:View": kde_set(bg, alt, fg),
        "Colors:Button": kde_set(alt, c["base02"], fg),
        "Colors:Header": kde_set(alt, bg, fg),
        "Colors:Header][Inactive": kde_set(bg, alt, fg),
        "Colors:Tooltip": kde_set(alt, c["base02"], fg),
        "Colors:Complementary": kde_set(alt, c["base02"], fg),
        "Colors:Selection": {
            **kde_set(sel_bg, sel_bg, sel_fg),
            "ForegroundActive": triple(sel_fg),
            "ForegroundInactive": triple(mix(sel_fg, sel_bg, 0.25)),
            "ForegroundLink": triple(sel_fg),
        },
        "WM": {
            "activeBackground": triple(bg),
            "activeForeground": triple(fg),
            "activeBlend": triple(fg),
            "inactiveBackground": triple(bg),
            "inactiveForeground": triple(readable(c["base04"], bg, fg, SOFT_CONTRAST + 1)),
            "inactiveBlend": triple(c["base04"]),
        },
    }
    with open(os.path.join(out, "kde.colors"), "w") as f:
        f.write(ini(kde))


if __name__ == "__main__":
    main()
