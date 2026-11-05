class Restaurant:
    """A simple model of a restaurant."""

    def __init__(self, restaurant_name, cuisine_type):
        """Initialize the restaurant attributes."""
        self.restaurant_name = restaurant_name
        self.cuisine_type = cuisine_type
        self.number_served = 0

    def describe_restaurant(self):
        """Print a description of the restaurant."""
        print(f"{self.restaurant_name} serves {self.cuisine_type} cuisine.")

    def open_restaurant(self):
        """Print a message indicating the restaurant is open."""
        print(f"{self.restaurant_name} is now open!")

    def set_number_served(self, number_served):
        """Set the number of customers served."""
        self.number_served = number_served

    def increment_number_served(self, additional_served):
        """Add to the number of customers served."""
        self.number_served += additional_served


class IceCreamStand(Restaurant):
    """A specific kind of restaurant that sells ice cream."""

    def __init__(self, restaurant_name, cuisine_type="ice cream"):
        """Initialize the parent class, then add flavors."""
        super().__init__(restaurant_name, cuisine_type)
        self.flavors = []

    def display_flavors(self):
        """Print the flavors available at the stand."""
        print(f"Flavors available at {self.restaurant_name}:")
        for flavor in self.flavors:
            print(f"- {flavor}")


stand = IceCreamStand("Scoops Ahoy")
stand.flavors = ["vanilla", "chocolate", "strawberry", "mint chip", "cookie dough"]

stand.describe_restaurant()
stand.display_flavors()