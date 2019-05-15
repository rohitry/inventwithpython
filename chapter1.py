# This is a guess the number game.
import random

guessestaken = 0

print(" Hello what is your name? ")
myName = input()
number = random.randint(1, 20)
print( 'Well, ' + myName + ' , I am thinking of number between 1 and 20.')

for guessesTaken in range(6):
	print('Take a guess.') # Four spaces in front of "print"
	guess = input()
	guess =int(guess)

	if guess < number:
		print('Your guess is too low.') # Eight spaces in front of "print"

	if guess > number:
		print('Your guess is too high.')

	if guess == number:
		break

if guess == number:
	guessesTaken = str(guessesTaken + 1)
	print('Good Job,' + myName + ' ! You guessed my number in ' + guessesTaken + ' guesses! ')

if guess != number:
	number = str(number)
	print('Nope. The number  was thinking of was ' + number + '.')