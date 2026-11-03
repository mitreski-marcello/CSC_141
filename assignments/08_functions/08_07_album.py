#Marcello Mitreski
# Chapter 8


def make_album(artist, title, songs=None):
    """Build a dictionary describing a music album."""
    album = {"artist": artist, "title": title}
    if songs:
        album["songs"] = songs
    return album


print(make_album("Daft Punk", "Discovery"))
print(make_album("Radiohead", "OK Computer"))
print(make_album("Kendrick Lamar", "good kid, m.A.A.d city"))

# With the optional number of songs
print(make_album("Fleetwood Mac", "Rumours", songs=11))