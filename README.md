# Wallet API

A service which generates Apple Wallet and Google Pay pass cards.

## Installation

You need to export several environment variables which are required for the service to function, the environment variables are present in the `.envrc.example` file.

## Usage

Start the application and request with a client on the route `/api/passbook` using the POST method, in the data field use this:

```
{
    "name": "An Event",
    "image": {
        "icon": "----REDACTED BASE64----",
        "logo": "----REDACTED BASE64----"
    },
    "ticketHolder": {
        "firstName": "John",
        "lastName": "Doe"
    },
    "location": {
        "latitude": 0.0,
        "longitude": 0.0,
        "name": "Local",
        "address": "Global"
    },
    "dateTime": {
        "start": "2022-05-04T06:28:56.054Z",
        "end": "2022-05-04T06:50:56.054Z"
    },
    "quickResponseCode": {
        "value": "Interesting day we are having, right?",
        "altText": "SCAN TO VERIFY"
    }
}
```

