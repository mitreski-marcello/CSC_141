#Marcello Mitreski
# Chapter 5


# Tests for equality and inequality with strings

car = 'bmw'
print("\nString equality/inequality")
print(car == 'bmw')        # True
print(car == 'audi')       # False
print(car != 'audi')       # True
print(car != 'bmw')        # False


# Tests using the lower() method

car = 'Audi'
print("\nlower() method")
print(car.lower() == 'audi')   # True
print(car.lower() == 'bmw')    # False



# Numerical tests: equality, inequality, >, <, >=, <=

age = 18
print("\nNumerical equality/inequality")
print(age == 18)   # True
print(age == 21)   # False
print(age != 21)   # True
print(age != 18)   # False

print("\nGreater than / less than ")
print(age > 12)    # True
print(age > 21)    # False
print(age < 21)    # True
print(age < 12)    # False

print("\n Greater than or equal to / less than or equal to ")
print(age >= 18)   # True
print(age >= 19)   # False
print(age <= 18)   # True
print(age <= 17)   # False



# Tests using 'and' and 'or'

age_0 = 22
age_1 = 18
print("\n 'and' keyword ")
print(age_0 >= 21 and age_1 >= 21)   # False (age_1 is not >= 21)
print(age_0 >= 21 and age_1 >= 18)   # True (both conditions true)

print("\n 'or' keyword ")
print(age_0 >= 21 or age_1 >= 21)    # True (age_0 satisfies it)
print(age_0 >= 30 or age_1 >= 30)    # False (neither satisfies it)


# Test whether an item is in a list

players = ['spiders', 'phantom', 'ghost', 'echo']
print("\n'in' list membership")
print('spiders' in players)   # True
print('viper' in players)     # False


# Test whether an item is not in a list

banned_users = ['troll1', 'griefer99']
print("\n'not in' list membership")
print('spiders' not in banned_users)   # True
print('troll1' not in banned_users)    # False