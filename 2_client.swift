/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 2_Client [V.V.V] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  network.swift demonstration program : client side

        Blablabla about the subject.

    DD/MM/YYYY > [V.V.V] :
    - Added something.
    - Added something else.

    DD/MM/YYYY > [V.V.V] :
    - Added something that wasn't before.
    - Fixed a bug.
    - Added something else.
    - Added something else again.

    BUGS : Active bugs in last version.
    NOTES : Notes.

    Contact : ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */




















// ---------------- DEFINITIONS ----------------

//connection
let ADDRESS : String = "127.0.0.1"
let PORT    : UInt16 = 8080



//message
let MESSAGE_LENGTH_MAX = 100




















// ---------------- EXECUTION ----------------

//presentation
print("Client > This is a basic demonstration of \"network.swift\" (client side).")






//TCP - IPv4 : START

//create socket
var nw = Network(NETWORK__CLIENT)

//try to connect
while !nw.connect(ADDRESS, PORT) {
	usleep(250000)
}
print("Client > Connected to server.")






//TCP - IPv4 : DATA TRANSFERS

//main loop
var message = RawPointer(MESSAGE_LENGTH_MAX)
while true {



	//RECEIVE

	//reset message
	message.reset()

	//receive reply
	nw.receiveFrom(
		nil,
		message.ptr,
		MESSAGE_LENGTH_MAX
	)

	//exit reply
	if message.compare("exit", 4) {
		print("Client > Exit request received.")
		break
	}

	//print reply
	print("Client > Message [\(message.toString())] received.")






	//SEND

	//reset message
	message.reset()

	//get user input
	print("Client > Write something to send to server : ", terminator: "")
	for i in 0..<(MESSAGE_LENGTH_MAX-1) { //-1 to leave the last byte at 0 ('\0')

		//get one character
		message._set(i, UInt8(getchar()) )

		//stop input at first line return
		if message._get(i) == UInt8(10) { //10 <=> '\n'
			message._set(i, UInt8(0))     //0 <=> '\0'
			break
		}
	}

	//send message
	nw.sendTo(
		nil,
		message.ptr,
		MESSAGE_LENGTH_MAX
	)

	//exit reply
	if message.compare("exit", 4) {
		print("Client > Exit request sent.")
		break
	}
	print("Client > Message [\(message.toString())] sent.")
}






//TCP - IPv4 : STOP

//end connection
nw.close()
print("Client > Ended network connection.")
