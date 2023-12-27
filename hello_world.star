load("render.star", "render")

def main():
    wide_row = render.Row(
        expanded=True,
        main_align="center",
        children=[
            render.Text("Hello World!"),
        ],
    )

    return render.Root(
        child = render.Column(
            expanded=True,
            main_align="center",
            children=[
                wide_row
            ],
        )
    )
