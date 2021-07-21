/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 1_Server [V.V.V] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                  network.swift demonstration program : server side

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




















// ---------------- IMPORTATIONS ----------------

//standard
import Foundation




















// ---------------- DEFINITIONS ----------------

//connection
let PORT : UInt16 = 8080

//message
let MESSAGE_LENGTH_MAX = 100




















// ---------------- EXECUTION ----------------

//presentation
print("Server > This is a basic demonstration of \"network.swift\" (server side).")






//TCP - IPv4 : START

//create socket
var nw = Network(NETWORK__SERVER)

//bind all addresses
nw.bind(PORT)

//accept the first address wanting to connect
var client        = nw.accept()
var clientAddress = String(
	format:"%08x",
	Int( client!.sock.sin_addr.s_addr )
)
print("Server > Accepted a client (address \"\(clientAddress)\").");






//TCP - IPv4 : DATA TRANSFERS

//main loop
var message = RawPointer(MESSAGE_LENGTH_MAX)
while true {



	//SEND

	//reset message
	message.reset()

	//get user input
	print("Server > Write something to send to client : ", terminator: "")
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
		client,
		message.ptr,
		MESSAGE_LENGTH_MAX
	)

	//exit reply
	if message.compare("exit", 4) {
		print("Server > Exit request sent.")
		break
	}
	print("Server > Message [\(message.toString())] sent.")






	//RECEIVE

	//reset message
	message.reset()

	//receive reply
	nw.receiveFrom(
		client,
		message.ptr,
		MESSAGE_LENGTH_MAX
	);

	//exit reply
	if message.compare("exit", 4) {
		print("Server > Exit request received.");
		break
	}

	//print reply
	print("Server > Message [\(message.toString())] received.");
}






//TCP - IPv4 : STOP

//end connection
nw.close()
print("Server > Ended network connection.");
