#Marcello Mitreski
# Chapter 6


favorite_languages = {
    'jen': 'python',
    'sarah': 'c',
    'edward': 'ruby',
    'phil': 'python',
}

people_to_poll = ['jen', 'edward', 'marcus', 'phil', 'priya', 'sarah']

for person in people_to_poll:
    if person in favorite_languages:
        print(f"Thank you for responding to the poll, {person.title()}!")
    else:
        print(f"{person.title()}, please take our favorite languages poll!")