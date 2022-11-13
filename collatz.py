# This program executes the collatz sequence which can take any number and reduce it back to zero
import sys
# Function collatz will evaluate whether the user number is odd or even and perform the apporiate calculation
def collatz(x):
    if abs(int(x)) % 2 == 0:
        return(int(x) // 2)
    else:
        return( 3 * abs(int(x)) + 1)


# This is the main program loop
while True:
    print('Input number or press q to quit.')
    number = input()
    if number == 'q':
        sys.exit() 
    else:
        try:                               #This loop checks to see if collatz has reached zero if it has it will exit
            while number != 1:
                number = collatz(number)
                print(number)
            print('Collatz produced 1!')
        except ValueError:
            print('The number needs to be an integer like 1, -45 , 63...')
