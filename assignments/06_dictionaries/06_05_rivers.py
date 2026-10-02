


rivers = {
    'nile': 'egypt',
    'amazon': 'brazil',
    'yangtze': 'china',
}

# Sentence about each river
for river, country in rivers.items():
    print(f"The {river.title()} runs through {country.title()}.")

print()

# Name of each river
print("Rivers in the dictionary:")
for river in rivers.keys():
    print(river.title())

print()

# Name of each country
print("Countries in the dictionary:")
for country in rivers.values():
    print(country.title())