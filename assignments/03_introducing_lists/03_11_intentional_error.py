#countries = ['Japan', 'Brazil', 'Kenya', 'Norway', 'Vietnam']

#print(countries[5])

#Traceback (most recent call last):
#  File "countries.py", line 3, in <module>
#    print(countries[5])
#IndexError: list index out of range

#Why it happens: the list has 5 items, so the valid indices are 0 through 4. 
#Index 5 would be a 6th item that doesn't exist, so Python raises IndexError.


#FIXED:

countries = ['Japan', 'Brazil', 'Kenya', 'Norway', 'Vietnam']

print(countries[4])

