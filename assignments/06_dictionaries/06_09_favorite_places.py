


favorite_places = {
    'maria': ['lisbon', 'central park'],
    'james': ['yosemite', 'tokyo', 'the grand canyon'],
    'priya': ['jaipur'],
}

for name, places in favorite_places.items():
    print(f"{name.title()}'s favorite places are:")
    for place in places:
        print(f"  - {place.title()}")
    print()