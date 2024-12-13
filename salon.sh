#!/bin/bash
PSQL='psql --username=freecodecamp --dbname=salon --tuples-only -c'

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  SERVICES=$( $PSQL "SELECT * FROM services;" )
  echo "$SERVICES" | while read ID BAR SERVICE; do
    echo -e "$ID) $SERVICE"  
  done

  read SERVICE_ID_SELECTED

  PICKED_SERVICE_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  if [[ -z $PICKED_SERVICE_RESULT ]]; then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    CUSTOMER_SERVICE=$(echo "$PICKED_SERVICE_RESULT" | sed "s/ //g")
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id,name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    CUSTOMER_ID=0
    CUSTOMER_NAME=""

    if [[ -z $CUSTOMER_ID_RESULT ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
    
      INSERT_USER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_ID=$NEW_CUSTOMER_ID
    else
      CUSTOMER_ID=$(echo "$CUSTOMER_ID_RESULT" | sed "s/ |.*//")
      CUSTOMER_NAME=$(echo "$CUSTOMER_ID_RESULT" | sed "s/.*| //")
    fi

    echo -e "\nWhat time would you like your $CUSTOMER_SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME

    APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    if [[ $APPOINTMENT_INSERT ]]; then
      echo -e "\nI have put you down for a $CUSTOMER_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME. \n"
    fi
  fi
}

MAIN_MENU
