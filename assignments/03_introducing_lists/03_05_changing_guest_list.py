guests = ['Albert Einstein', 'Abraham Lincoln', 'Marie Curie']

print(f"Dear {guests[0]}, you are invited to dinner.")
print(f"Dear {guests[1]}, you are invited to dinner.")
print(f"Dear {guests[2]}, you are invited to dinner.")

print(f"\n{guests[1]} can't make it to dinner.")

# Replace the guest who can't come
guests[1] = 'Isaac Newton'

print(f"\nDear {guests[0]}, you are invited to dinner.")
print(f"Dear {guests[1]}, you are invited to dinner.")
print(f"Dear {guests[2]}, you are invited to dinner.")