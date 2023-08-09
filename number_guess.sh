#!/bin/bash

PSQL="psql -U freecodecamp --dbname=number_guess -t --no-align -q -c"

USER() {
  echo "Enter your username:"
  read USERNAME
  if [[ ${#USERNAME} -gt 22 ]]
  then
    echo "Username Too Long"
    USER
    return
  fi

  USERNAME_CHECK=$($PSQL "select games_played, best_game from users where username='$USERNAME'")
  if [[ -z $USERNAME_CHECK ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    $PSQL "insert into users(username, games_played) values('$USERNAME', 0)"
  else
    IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USERNAME_CHECK"
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

GAME() {
  echo "Guess the secret number between 1 and 1000:"

  SECRET=$(( 1 + RANDOM % 1000 ))
  COUNT=1

  echo "Secret: $SECRET"

  while [[ $GUESS -ne $SECRET ]]
  do
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS -lt $SECRET ]]
    then
      echo "It's higher than that, guess again:"
      (( COUNT++ ))
    elif [[ $GUESS -gt $SECRET  ]]
    then
      echo "It's lower than that, guess again:"
      (( COUNT++ ))
    fi
  done

  $PSQL "update users set games_played=games_played + 1 where username='$USERNAME'"

  if [[ -z $BEST_GAME || $BEST_GAME -gt $COUNT ]]
  then
    $PSQL "update users set best_game=$COUNT where username='$USERNAME'"
  fi

  echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"
}

MAIN() {
  USER
  GAME
}

MAIN

# database number_guess columns user_id username games_played best_game
