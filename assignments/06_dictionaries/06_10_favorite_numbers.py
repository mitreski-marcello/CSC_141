#Marcello Mitreski
# Chapter 5


favorite_numbers = {
    'maria': [7, 21],
    'james': [3, 14, 42],
    'priya': [9],
    'chen': [8, 88],
    'sam': [1, 13, 100],
}

for name, numbers in favorite_numbers.items():
    print(f"{name.title()}'s favorite numbers are:")
    for number in numbers:
        print(f"  {number}")
    print()