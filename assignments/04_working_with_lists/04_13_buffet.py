#Marcello Mitreski
# Chapter 4

# Create a tuple of five basic foods offered at the buffet
foods = ("pizza", "pasta", "chicken", "rice", "vegetables")

# Print each food the restaurant offers using a for loop
print("Foods offered at the buffet:")
for food in foods:
    print(food)

# Try to modify one of the items (this will cause an error)
print("\nAttempting to change the first item...")
try:
    foods[0] = "salad"
except TypeError as e:
    print(f"Error: {e}")
    print("You cannot modify a tuple!")

# The restaurant changes its menu - replace two items with different foods
print("\nThe restaurant has updated its menu!")
foods = ("pizza", "pasta", "fish", "potatoes", "salad")

# Print each item on the revised menu using a for loop
print("Updated foods offered at the buffet:")
for food in foods:
    print(food)