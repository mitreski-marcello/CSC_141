#Marcello Mitreski
# Chapter 8


def make_album(artist, title, songs=None):
    """Build a dictionary describing a music album."""
    album = {"artist": artist, "title": title}
    if songs:
        album["songs"] = songs
    return album


while True:
    print("\nEnter an album's info (enter 'q' at any time to quit)")

    artist = input("Artist name: ")
    if artist == "q":
        break

    title = input("Album title: ")
    if title == "q":
        break

    album = make_album(artist, title)
    print(album)