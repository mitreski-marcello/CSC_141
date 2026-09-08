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