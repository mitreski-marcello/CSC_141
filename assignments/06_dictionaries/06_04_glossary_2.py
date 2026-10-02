


glossary = {
    'variable': 'A name that stores a value so you can use it later.',
    'string': 'A series of characters, written inside quotes.',
    'list': 'An ordered collection of items that you can change.',
    'loop': 'A way to repeat a block of code for each item or until a condition changes.',
    'dictionary': 'A collection of key-value pairs, where each key maps to a value.',
    # Five new terms
    'tuple': 'An ordered collection of items that cannot be changed after it is created.',
    'index': 'The position of an item in a list, starting at 0 for the first item.',
    'f-string': 'A string with an f before the quotes that lets you put variables inside curly braces.',
    'boolean': 'A value that is either True or False.',
    'function': 'A named block of code that performs a task when you call it.',
}

for word, meaning in glossary.items():
    print(f"{word.title()}:\n{meaning}\n")