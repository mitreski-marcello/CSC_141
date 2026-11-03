#Marcello Mitreski
# Chapter 8


def make_album(artist, title, songs=None):
    """Build a dictionary describing a music album."""
    album = {"artist": artist, "title": title}
    if songs is not None:
        album["songs"] = songs
    return album


print(make_album("Daft Punk", "Discovery"))
print(make_album("Radiohead", "OK Computer"))
print(make_album("Kendrick Lamar", "good kid, m.A.A.d city"))
print(make_album("Fleetwood Mac", "Rumours", songs=11))


"""
songs=None has no spaces around =, and so does the songs=11 keyword argument in the last call.

The docstring sits directly under the def line.

Two blank lines separate the function from the calls.

I changed if songs: to if songs is not None:. That’s the style PEP 8 prefers when you’re checking for None, and it also handles a song count of 0 correctly.

"""