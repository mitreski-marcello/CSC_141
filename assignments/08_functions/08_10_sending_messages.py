#Marcello Mitreski
# Chapter 8


def show_messages(messages):
    """Print each text message in the list."""
    for message in messages:
        print(message)


def send_messages(messages, sent_messages):
    """Print each message and move it to the sent_messages list."""
    while messages:
        current_message = messages.pop()
        print(f"Sending message: {current_message}")
        sent_messages.append(current_message)


texts = [
    "Hey, are we still on for tonight?",
    "Running 5 minutes late.",
    "Don't forget to bring the charger.",
    "Scrim starts at 8, be on comms.",
]
sent_messages = []

send_messages(texts, sent_messages)

print("\nOriginal list:")
print(texts)

print("\nSent messages:")
print(sent_messages)