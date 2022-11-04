import random
import sys
# This defines my function for the 8-ball and possible outcomes


def shake_ball(outcome):
    if outcome == 1:
        print('Try again later...')
    elif outcome == 2:
        print('It is certain')
    elif outcome == 3:
        print('Most likely')
    elif outcome == 4:
        print('NOT HAPPENING')
    elif outcome == 5:
        print('Not likely')
    elif outcome == 6:
        print('Absolutely')
    elif outcome == 7:
        print('No way jose')
# This is the main program loop


while True:
    print('Would you like to ask the (8) Ball a question')
    answer = input()
    if answer == 'Yes' or answer == 'yes':
        print('Ask your question')
        input()
        r = random.randint(1, 7)
        shake_ball(r)
    elif answer == 'no' or answer == 'No':
        print('Thanks for visiting press any key to quit.')
        input()
        sys.exit()
    else: print('Answer must be yes or no.')
