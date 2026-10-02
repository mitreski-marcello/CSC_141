#Marcello Mitreski
# Chapter 5


cities = {
    'tokyo': {
        'country': 'japan',
        'population': 14_000_000,
        'fact': 'it is home to the busiest pedestrian crossing in the world, at Shibuya.',
    },
    'cairo': {
        'country': 'egypt',
        'population': 10_000_000,
        'fact': 'it is the largest city in the Arab world.',
    },
    'reykjavik': {
        'country': 'iceland',
        'population': 140_000,
        'fact': 'it is the northernmost capital of a sovereign state.',
    },
}

for city, info in cities.items():
    print(f"{city.title()}:")
    print(f"  Country: {info['country'].title()}")
    print(f"  Population: {info['population']:,}")
    print(f"  Fact: {info['fact'].capitalize()}")
    print()