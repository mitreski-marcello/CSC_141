#Marcello Mitreski
# Chapter 4

# Original list of pizzas
pizzas = ["pepperoni", "margherita", "BBQ chicken"]

# Make a copy of the list for friend_pizzas
friend_pizzas = pizzas.copy()

# Add a new pizza to the original list
pizzas.append("Hawaiian")

# Add a different pizza to friend_pizzas
friend_pizzas.append("veggie")

# Print my favorite pizzas using a for loop
print("My favorite pizzas are:")
for pizza in pizzas:
    print(pizza)

# Print my friend's favorite pizzas using a for loop
print("\nMy friend's favorite pizzas are:")
for pizza in friend_pizzas:
    print(pizza)