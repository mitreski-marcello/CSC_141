#Marcello Mitreski
# Chapter 8


def show_messages(messages):
    """Print each text message in the list."""
    for message in messages:
        print(message)


texts = [
    "Hey, are we still on for tonight?",
    "Running 5 minutes late.",
    "Don't forget to bring the charger.",
    "Scrim starts at 8, be on comms.",
]

show_messages(texts)