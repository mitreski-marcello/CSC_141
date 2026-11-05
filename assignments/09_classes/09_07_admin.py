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
        self.login_attempts = 0

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

    def increment_login_attempts(self):
        """Increment the value of login_attempts by 1."""
        self.login_attempts += 1

    def reset_login_attempts(self):
        """Reset the value of login_attempts to 0."""
        self.login_attempts = 0


class Admin(User):
    """A special kind of user with administrative privileges."""

    def __init__(self, first_name, last_name, username, email, location, occupation):
        """Initialize the parent class, then add privileges."""
        super().__init__(first_name, last_name, username, email, location, occupation)
        self.privileges = [
            "can add post",
            "can delete post",
            "can ban user",
            "can edit user accounts",
        ]

    def show_privileges(self):
        """Print the administrator's set of privileges."""
        print(f"Privileges for {self.username}:")
        for privilege in self.privileges:
            print(f"- {privilege}")


admin = Admin("Grace", "Hopper", "ghopper", "grace@example.com", "New York, USA", "Site administrator")

admin.describe_user()
admin.greet_user()
print()
admin.show_privileges()