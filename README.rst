Twit
====

Is a dumb Twitter clone written in Haskell and Scotty.

Steps
=====

First, clone this repository. Make sure you can build and run the project: ``stack build; stack exec twit``.

Then try making a tweet: ``http POST localhost:3000/tweets User=yournamehere Content=yourcontenthere``. I'm using `httpie <https://github.com/jakubroztocil/httpie>`_ in these examples, but curl or any other HTTP client would work too.

.. code::

    ❯❯❯ http POST localhost:3000/tweets User=hao Content=hello
    HTTP/1.1 200 OK
    Content-Type: application/json; charset=utf-8
    Date: Thu, 22 Mar 2018 17:35:36 GMT
    Server: Warp/3.2.18.1
    Transfer-Encoding: chunked

    {
        "Content": "hello",
        "ID": 0,
        "Replies": null,
        "User": "hao"
    }

You should now be able to read the tweet back:

- ``http GET localhost:3000/tweets``
- ``http GET localhost:3000/tweets/0``


.. code::
    ❯❯❯ http GET localhost:3000/tweets/0
    HTTP/1.1 200 OK
    Content-Type: application/json; charset=utf-8
    Date: Thu, 22 Mar 2018 17:35:47 GMT
    Server: Warp/3.2.18.1
    Transfer-Encoding: chunked

    {
        "Content": "hello",
        "ID": 0,
        "Replies": [],
        "User": "hao"
    }
