guests = ['Albert Einstein', 'Abraham Lincoln', 'Marie Curie']

print(f"Dear {guests[0]}, you are invited to dinner.")
print(f"Dear {guests[1]}, you are invited to dinner.")
print(f"Dear {guests[2]}, you are invited to dinner.")

print("\nGood news, I found a bigger table!")

guests.insert(0, 'Nikola Tesla')
guests.insert(2, 'Ada Lovelace')
guests.append('Charles Darwin')

print()
for guest in guests:
    print(f"Dear {guest}, you are invited to dinner.")

print("\nBad news, the table won't arrive in time. I can only invite two people now.")

while len(guests) > 2:
    removed_guest = guests.pop()
    print(f"Sorry {removed_guest}, I can't invite you to dinner.")

print()
for guest in guests:
    print(f"Dear {guest}, you're still invited to dinner.")

del guests[0]
del guests[0]

print(f"\nGuest list: {guests}")