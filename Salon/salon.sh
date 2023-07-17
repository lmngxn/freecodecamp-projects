#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Welcome to the Hair Salon ~~~\n"

MAIN_MENU() {
  MAX_SERVICE=$($PSQL "SELECT MAX(service_id) FROM services") 

  if [[ ! -z $1 ]]
  then
    echo $1
  else
    echo Welcome to My Salon, how can I help you?
  fi
  SERVICES=$($PSQL "SELECT * FROM services") 
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ && $SERVICE_ID_SELECTED -gt 0 && $SERVICE_ID_SELECTED -le $MAX_SERVICE ]]
  then
    SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED
  else
    MAIN_MENU 'I could not find that service. What would you like today?'  
  fi
}

SCHEDULE_APPOINTMENT() {
  SERVICE_ID=$1
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$(echo $($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'") | sed -E 's/^ *| *$//')
  fi
  SERVICE_NAME=$(echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID") | sed -E 's/^ *| *$//')
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


MAIN_MENU