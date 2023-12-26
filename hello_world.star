load("render.star", "render")

def main():
    return render.Root(
        child = render.Column(
            cross_align="center",
            children=[
                render.Text("Podcast is Now!"),
            ],
        )
    )
