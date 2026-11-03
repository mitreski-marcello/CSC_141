#Marcello Mitreski
# Chapter 8


def make_shirt(size="large", message="I love Python"):
    """Summarize the size and message of a shirt."""
    print(f"The shirt is size {size} and says: '{message}'")


# Large shirt with the default message
make_shirt()

# Medium shirt with the default message
make_shirt(size="medium")

# Shirt of any size with a different message
make_shirt("small", "Debugging is my cardio")