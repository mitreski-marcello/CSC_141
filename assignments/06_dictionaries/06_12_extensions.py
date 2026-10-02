#Marcello Mitreski
# Chapter 5 


cities = {
    'tokyo': {
        'country': 'japan',
        'continent': 'asia',
        'population': 14_000_000,
        'fact': 'it has the busiest pedestrian crossing in the world, at Shibuya.',
        'landmarks': ['senso-ji', 'tokyo skytree', 'meiji shrine'],
        'visited': True,
    },
    'cairo': {
        'country': 'egypt',
        'continent': 'africa',
        'population': 10_000_000,
        'fact': 'it is the largest city in the Arab world.',
        'landmarks': ['giza pyramids', 'egyptian museum'],
        'visited': False,
    },
    'reykjavik': {
        'country': 'iceland',
        'continent': 'europe',
        'population': 140_000,
        'fact': 'it is the northernmost capital of a sovereign state.',
        'landmarks': ['hallgrimskirkja', 'harpa concert hall'],
        'visited': False,
    },
}

# Add a new city after the fact
cities['lima'] = {
    'country': 'peru',
    'continent': 'south america',
    'population': 10_000_000,
    'fact': 'it is one of the driest capital cities in the world.',
    'landmarks': ['plaza mayor', 'larco museum'],
    'visited': True,
}

print("=" * 40)
print("MY TRAVEL PLANNER")
print("=" * 40)

for city, info in cities.items():
    status = "Visited" if info['visited'] else "On my list"
    print(f"\n{city.title()}, {info['country'].title()} [{status}]")
    print("-" * 40)
    print(f"{'Continent:':<12}{info['continent'].title()}")
    print(f"{'Population:':<12}{info['population']:,}")
    print(f"{'Fact:':<12}{info['fact'].capitalize()}")
    print(f"{'Landmarks:':<12}{', '.join(l.title() for l in info['landmarks'])}")

# Summary
visited = [city.title() for city, info in cities.items() if info['visited']]
to_visit = [city.title() for city, info in cities.items() if not info['visited']]

print("\n" + "=" * 40)
print(f"Visited ({len(visited)}): {', '.join(visited)}")
print(f"Still to go ({len(to_visit)}): {', '.join(to_visit)}")