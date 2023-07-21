#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RAND_NUM=$(($RANDOM % 1000 + 1))

echo Enter your username:
read USERNAME
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME' ")
if [[ -z $USER_INFO ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  echo $USER_INFO | while IFS='|' read USER_ID GAMES_PLAYED BEST_GAME
  do
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  done 
fi
COUNTER=$((0))
echo Guess the secret number between 1 and 1000:
read NUM
while [[ $NUM != $RAND_NUM ]]
do
  if [[ ! $NUM =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $NUM -lt $RAND_NUM ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  (( COUNTER += 1 )) 
  read NUM
done
(( COUNTER += 1 )) 
echo "You guessed it in $COUNTER tries. The secret number was $RAND_NUM. Nice job!"
if [[ -z $USER_INFO ]]
then
  INSERT_INTO_DATABASE=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $COUNTER)")
else
  if [[ $COUNTER -lt $BEST_GAME ]]
  then
    MODIFY_DATABASE=$($PSQL "UPDATE users SET best_game=$COUNTER")
  fi
  (( GAMES_PLAYED += 1 ))
  MODIFY_DATABASE=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED")
fi