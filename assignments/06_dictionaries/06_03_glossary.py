#Marcello Mitreski
# Chapter 6


glossary = {
    'variable': 'A name that stores a value so you can use it later.',
    'string': 'A series of characters, written inside quotes.',
    'list': 'An ordered collection of items that you can change.',
    'loop': 'A way to repeat a block of code for each item or until a condition changes.',
    'dictionary': 'A collection of key-value pairs, where each key maps to a value.',
}

for word, meaning in glossary.items():
    print(f"{word.title()}:\n{meaning}\n")