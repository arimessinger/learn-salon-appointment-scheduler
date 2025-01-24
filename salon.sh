#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

display_services() {
  echo "Here are the services we offer:"
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")" | while IFS="|" read service_id service_name
  do
    echo "$service_id) $service_name"
  done
}

display_services

while true
do
  echo -e "\nPlease enter the service number you'd like to book:"
  read SERVICE_ID_SELECTED

  SERVICE_EXISTS=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  
  if [[ "$SERVICE_EXISTS" -eq 1 ]]
  then
    echo "You selected service number $SERVICE_ID_SELECTED."
    break
  else
    echo "Invalid service number. Please try again."
    display_services
  fi
done

echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

CUSTOMER_EXISTS=$($PSQL "SELECT COUNT(*) FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [[ "$CUSTOMER_EXISTS" -eq 1 ]]
then
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  echo "Welcome back, $CUSTOMER_NAME!"
else
  echo "It seems like you're a new customer. Please enter your name:"
  read CUSTOMER_NAME
fi

echo -e "\nPlease enter the time for your appointment:"
read SERVICE_TIME

if [[ "$CUSTOMER_EXISTS" -eq 0 ]]
then
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  echo "Thank you, $CUSTOMER_NAME. Your information has been added to our system."
fi

INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) 
SELECT customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME' 
FROM customers WHERE phone = '$CUSTOMER_PHONE';")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
