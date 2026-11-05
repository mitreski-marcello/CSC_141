class Restaurant:
    """A simple model of a restaurant."""

    def __init__(self, restaurant_name, cuisine_type):
        """Initialize the restaurant name and cuisine type attributes."""
        self.restaurant_name = restaurant_name
        self.cuisine_type = cuisine_type

    def describe_restaurant(self):
        """Print a description of the restaurant."""
        print(f"{self.restaurant_name} serves {self.cuisine_type} cuisine.")

    def open_restaurant(self):
        """Print a message indicating the restaurant is open."""
        print(f"{self.restaurant_name} is now open!")

    def set_number_served(self, number_served):
        """Set the number of customers served."""
        self.number_served = number_served


restaurant = Restaurant("Luigi's", "Italian")

print(restaurant.restaurant_name)
print(restaurant.cuisine_type)
restaurant.set_number_served(50)
print(restaurant.number_served)

restaurant.describe_restaurant()
restaurant.open_restaurant()