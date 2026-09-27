#Marcello Mitreski
# Chapter 5


#Checking Usernames
current_users = ['spiders', 'Ghost', 'Phantom', 'Echo', 'Viper']

new_users = ['Spiders', 'raze', 'Sova', 'GHOST', 'jett']

# Make a case-insensitive copy of current_users
current_users_lower = [user.lower() for user in current_users]

for new_user in new_users:
    if new_user.lower() in current_users_lower:
        print(f"Sorry, '{new_user}' is already taken. Please enter a new username.")
    else:
        print(f"'{new_user}' is available.")