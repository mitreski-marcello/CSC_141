#Marcello Mitreski
# Chapter 3

countries = ['Japan', 'Brazil', 'Kenya', 'Norway', 'Vietnam']

# Access individual elements
print(f"The first country on my list is {countries[0]}.")
print(f"The last country on my list is {countries[-1]}.")

# for loop
print("\nCountries I'd like to visit:")
for country in countries:
    print(f"- {country}")

# len()
print(f"\nI have {len(countries)} countries on my list.")

# append()
countries.append('Iceland')
print(f"\nAfter append(): {countries}")

# insert()
countries.insert(0, 'Peru')
print(f"After insert(): {countries}")

# del
del countries[1]
print(f"After del: {countries}")

# pop()
popped_country = countries.pop()
print(f"After pop(): {countries}")
print(f"I removed {popped_country} from the list.")

# sorted() - doesn't change original
print(f"\nSorted (not permanent): {sorted(countries)}")
print(f"Original order still: {countries}")

# sort() - changes original permanently
countries.sort()
print(f"\nAfter sort(): {countries}")

# reverse()
countries.reverse()
print(f"After reverse(): {countries}")