#Marcello Mitreski
# Chapter 6


pet_1 = {
    'animal': 'dog',
    'owner': 'maria',
}

pet_2 = {
    'animal': 'cat',
    'owner': 'james',
}

pet_3 = {
    'animal': 'parrot',
    'owner': 'priya',
}

pet_4 = {
    'animal': 'hamster',
    'owner': 'chen',
}

pets = [pet_1, pet_2, pet_3, pet_4]

for pet in pets:
    print(f"Animal: {pet['animal'].title()}")
    print(f"  Owner: {pet['owner'].title()}")
    print()