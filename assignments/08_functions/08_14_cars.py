#Marcello Mitreski
# Chapter 8


def make_car(manufacturer, model, **car_info):
    """Build a dictionary of information about a car."""
    car_info["manufacturer"] = manufacturer
    car_info["model"] = model
    return car_info


car = make_car("subaru", "outback", color="blue", tow_package=True)
print(car)

# Another call with two other key-value pairs
car = make_car("toyota", "supra", color="red", year=1998)
print(car)