#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TRUNCATE_RESULT=$($PSQL "TRUNCATE games, teams RESTART IDENTITY")
if [[ $TRUNCATE_RESULT != "TRUNCATE TABLE" ]]
then
  echo ERROR: Was NOT able to reset tables.
  exit
fi
echo Reset tables.

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    if [[ -z $WINNER_TEAM_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT != "INSERT 0 1" ]]
      then
        echo ERROR: Was NOT able to insert $WINNER into teams.
        exit
      fi
      echo Inserted $WINNER into teams.
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT != "INSERT 0 1" ]]
      then
        echo ERROR: Was NOT able to insert $OPPONENT into teams.
        exit
      fi
      echo Inserted $OPPONENT into teams.
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT != "INSERT 0 1" ]]
    then
      echo ERROR: Was NOT able to insert the $YEAR game where $WINNER beat $OPPONENT into games: $INSERT_GAME_RESULT
      exit
    fi
    echo Inserted the $YEAR game where $WINNER beat $OPPONENT into games.
  fi
done