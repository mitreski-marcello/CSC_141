#Marcello Mitreski
# Chapter 5


person_1 = {
    'first_name': 'ada',
    'last_name': 'lovelace',
    'age': 36,
    'city': 'london',
}

person_2 = {
    'first_name': 'grace',
    'last_name': 'hopper',
    'age': 85,
    'city': 'new york',
}

person_3 = {
    'first_name': 'alan',
    'last_name': 'turing',
    'age': 41,
    'city': 'wilmslow',
}

people = [person_1, person_2, person_3]

for person in people:
    full_name = f"{person['first_name'].title()} {person['last_name'].title()}"
    print(f"Name: {full_name}")
    print(f"  Age: {person['age']}")
    print(f"  City: {person['city'].title()}")
    print()