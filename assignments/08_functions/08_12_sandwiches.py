#Marcello Mitreski
# Chapter 8


def make_sandwich(*items):
    """Summarize the items being put on a sandwich."""
    print("\nMaking a sandwich with the following items:")
    for item in items:
        print(f"- {item}")


make_sandwich("turkey")
make_sandwich("ham", "swiss cheese", "lettuce")
make_sandwich("roast beef", "cheddar", "tomato", "onion", "mustard")