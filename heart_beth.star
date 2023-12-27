load("render.star", "render")
load("encoding/base64.star", "base64")

HEART_IMG= base64.decode("R0lGODlhEAAQAPMPAP+bmwAAAGYAAOMAAIYAAI0AAPIAAL0CArcAAIAAANAAAP+4uP9sbP/5+f8AAAAAACH5BAUAAA8ALAAAAAAQABAAQARe8L1Aqaz2Isd7R0IwGQzjnUoiSpfhHMTKBsLRxQHBHUg1nMBDYUX7dQypDGsmCC1nBYVigBkYeKKAq7HgJBKegypgBH5wBkDX7BgMJ4KCuRCSTQKeAe7JLOz5T0pLEQA7")

def center(widgets):
    """
    Centers the given list of widgets.
    """
    wide_row = render.Row(
        expanded=True,
        main_align="center",
        children=widgets,
    )

    return vertical_center(wide_row)

def vertical_center(widget):
    """
    Center the widget vertically.
    """
    return render.Column(
        expanded=True,
        main_align="center",
        children=[widget],
    )

def main():
    # There must be a better way to handle the centering
    return render.Root(
        child=center([
            vertical_center(render.Image(src=HEART_IMG)),
            vertical_center(render.Text(" ")),
            vertical_center(render.Text("Beth")),
        ])
    )
