#Marcello Mitreski
# Chapter 8


def make_shirt(size, message):
    """Summarize the size and message of a shirt."""
    print(f"The shirt is size {size} and says: '{message}'")


# Positional arguments
make_shirt("large", "I love Python")

# Keyword arguments
make_shirt(size="medium", message="Functions are fun")