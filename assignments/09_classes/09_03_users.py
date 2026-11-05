class User:
    """A simple model of a user profile."""

    def __init__(self, first_name, last_name, username, email, location, occupation):
        """Initialize the user's profile attributes."""
        self.first_name = first_name
        self.last_name = last_name
        self.username = username
        self.email = email
        self.location = location
        self.occupation = occupation

    def describe_user(self):
        """Print a summary of the user's information."""
        print(f"Name: {self.first_name} {self.last_name}")
        print(f"Username: {self.username}")
        print(f"Email: {self.email}")
        print(f"Location: {self.location}")
        print(f"Occupation: {self.occupation}")

    def greet_user(self):
        """Print a personalized greeting to the user."""
        print(f"Welcome back, {self.first_name}!")


user_1 = User("Ada", "Lovelace", "alove", "ada@example.com", "London, England", "Mathematician")
user_2 = User("Grace", "Hopper", "ghopper", "grace@example.com", "New York, USA", "Computer scientist")
user_3 = User("Linus", "Torvalds", "ltorvalds", "linus@example.com", "Portland, Oregon", "Software engineer")

user_1.describe_user()
user_1.greet_user()
print()

user_2.describe_user()
user_2.greet_user()
print()

user_3.describe_user()
user_3.greet_user()