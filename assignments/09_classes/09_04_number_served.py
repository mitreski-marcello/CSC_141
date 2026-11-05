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


restaurant = Restaurant("Luigi's Trattoria", "Italian")

# Default value
print(f"Customers served: {restaurant.number_served}")

# Change the value directly
restaurant.number_served = 25
print(f"Customers served: {restaurant.number_served}")

# Change it with set_number_served()
restaurant.set_number_served(40)
print(f"Customers served: {restaurant.number_served}")

# Increment it with increment_number_served()
restaurant.increment_number_served(120)
print(f"Customers served: {restaurant.number_served}")