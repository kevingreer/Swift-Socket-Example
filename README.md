# Swift-Socket-Example

To start the server, simply run `python server.py`

Once the server is running, you can simply run the iOS client and start sending messages in real-time.

If you'd like to set up a second client through the command line, you can do so with telnet. In a separate terminal instance type `telnet localhost 80`. The protocol for the server is this: to join the chat room send the command `iam:<name>` to the server. To send a message sent the command `msg:<message>`.
