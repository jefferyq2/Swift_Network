/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Network [0.1.0] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                 Network by I.A.

        Network is an utility program that allows you to create and join
    networks using TCP in IPv4 in Swift.

    15/04/2021 > [0.1.0] :
    - Created network.swift.
    - Implemented TCP in IPv4.

    BUGS : .
    NOTES : .

    Contact     : i.a.sebsil83@gmail.com
    Youtube     : https://www.youtube.com/user/IAsebsil83
    GitHub repo : https://github.com/iasebsil83

    Let's Code !                                  By I.A.
*********************************************************************************
    LICENCE :
    Swift_Network
    Copyright (C) 2021  Sebastien SILVANO
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.
    If not, see <https://www.gnu.org/licenses/>.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */




















// -------------------------------- DEFINITIONS --------------------------------

//owners
let NETWORK__CLIENT : UInt8 = 0x00
let NETWORK__SERVER : UInt8 = 0x01



//listen() backlog
let NETWORK__LISTEN_BACKLOG : Int32 = 5



//socket structure
let NETWORK__SOCK_STREAM : Int32  = 1
let NETWORK__SOCK_SIZE   : UInt32 = 16 //in C : sizeof(struct sockaddr_in)
                                     //on 64 bits standard linux computer



















// -------------------------------- BASICS --------------------------------

//class
class Network {

	//attributes
	var owner : UInt8
	var fd    : Int32
	var sock  : sockaddr_in = sockaddr_in()



	//init - close
	init(_ owner:UInt8) {

		//set owner
		self.owner = owner

		//reset socket structure (just in case)
		bzero( &(self.sock), Int(NETWORK__SOCK_SIZE))

		//create socket
		self.fd = socket(AF_INET, NETWORK__SOCK_STREAM, 0)
		if self.fd == -1 {
			print("RUNTIME ERROR > network.swift : Network.create() : Could not create socket.")
		}
	}

	func close() {

		//flush data in socket
		while SwiftGlibc.close(self.fd) == -1 {
		}
	}



	//connect - bind - accept
	func bind(_ port:UInt16) { //available for servers only

		//error case
		if self.owner == NETWORK__CLIENT {
			print("RUNTIME ERROR > network.swift : Network.bind() : Network instance is set as \"CLIENT\" and clients cannot use Network.bind().")
			return
		}

		//reset socket structure
		bzero( &(self.sock), Int(NETWORK__SOCK_SIZE))

		//set socket structure
		self.sock.sin_family      = UInt16(AF_INET)
		self.sock.sin_addr.s_addr = htonl(INADDR_ANY) //all addresses are bound
		self.sock.sin_port        = htons(port)

		//cast sock from sockaddr_in into sockaddr
		let sock_raw      : UnsafeRawPointer = UnsafeRawPointer( &self.sock )
		var sock_sockaddr : sockaddr         = sock_raw.advanced(
			by: 0
		).load(
			as: sockaddr.self
		)

		//bind
		var errorCode : Int32 = SwiftGlibc.bind(
			self.fd,
			&sock_sockaddr,
			NETWORK__SOCK_SIZE
		);
		if errorCode == -1 {
			print("RUNTIME ERROR > network.swift : Network.bind() : Could not bind all addresses [\(errorCode)].")
			return
		}

		//listen
		errorCode = listen(self.fd, NETWORK__LISTEN_BACKLOG)
		if errorCode != 0 {
			print("RUNTIME ERROR > network.swift : Network.bind() : Could not listen [\(errorCode)].")
			return
		}
	}

	func accept() -> Network? { //available for servers only

		//error case
		if self.owner == NETWORK__CLIENT {
			print("RUNTIME ERROR > network.swift : Network.accept() : Network instance is set as \"CLIENT\" and clients cannot use Network.accept().")
			return nil
		}

		//create new client instance
		var client_nw : Network? = Network(NETWORK__CLIENT)

		//cast sock from sockaddr_in into sockaddr
		var client_sock_sockaddr : sockaddr = UnsafeRawPointer( &client_nw!.sock ).advanced(
			by: 0
		).load(
			as: sockaddr.self
		)

	    //accept new client
	    var size : UInt32 = NETWORK__SOCK_SIZE
	    client_nw!.fd = SwiftGlibc.accept(
			self.fd,
			&client_sock_sockaddr,
			&size
		)

		return client_nw
	}

	func connect(_ address:String, _ port:UInt16) -> Bool { //available for clients only

		//error cases
		if self.owner == NETWORK__SERVER {
			print("RUNTIME ERROR > network.swift : Network.connect() : Network instance is set as \"SERVER\" and servers cannot use Network.connect().")
			return false
		}

		//reset socket structure
		bzero( &(self.sock), Int(NETWORK__SOCK_SIZE))

		//set formatted address
		var errorCode : Int32 = inet_pton(
			AF_INET,
			address,
			&( (self.sock).sin_addr )
		)
		if errorCode != 1 {
			print("RUNTIME ERROR > network.swift : Network.connect() : Invalid IPv4 address given \"\(address)\" [\(errorCode)].")
			return false
		}

		//set the other fields
		self.sock.sin_family = UInt16(AF_INET)
		self.sock.sin_port   = htons(port)

		//cast sock from sockaddr_in into sockaddr
		let sock_raw      : UnsafeRawPointer = UnsafeRawPointer( &self.sock )
		var sock_sockaddr : sockaddr         = sock_raw.advanced(
			by: 0
		).load(
			as: sockaddr.self
		)

		//connect
		errorCode = SwiftGlibc.connect(
			self.fd,
			&sock_sockaddr,
			NETWORK__SOCK_SIZE
		);
		if errorCode != 0 {
			print("RUNTIME ERROR > network.swift : Network.connect() : Could not connect to server [\(errorCode)].")
			return false
		}

		//connection established
		return true
	}



	//sendTo - receiveFrom
	func sendTo(_ dest:Network?, _ data:UnsafeMutableRawPointer, _ length:Int){ // #data# must not be nil or unallocated
		var errorCode : Int = 0

		//server
		if self.owner == NETWORK__SERVER {
			if dest == nil {
				print("RUNTIME ERROR > network.swift : Network.sendTo() : Destination network instance is nil.")
				return
			}
			errorCode = send(
				dest!.fd,
				data,
				length,
				Int32(0) //flags
			)
		}

		//client
		else{
			errorCode = send(
				self.fd,
				data,
				length,
				Int32(0) //flags
			)
		}

		//errors
		if errorCode != length {
			print("RUNTIME ERROR > network.swift : Network.sendTo() : Error sending data [\(errorCode)].")
		}
	}

	func receiveFrom(_ dest:Network?, _ data:UnsafeMutableRawPointer, _ length:Int){ // #data# shall be nil or unallocated
		var errorCode : Int = 0

		//server
		if self.owner == NETWORK__SERVER {
			if dest == nil {
				print("RUNTIME ERROR > network.swift : Network.receiveFrom() : Destination network instance is nil.")
				return
			}
			errorCode = recv(
				dest!.fd,
				data,
				length,
				Int32(0) //flags
			)
		}

		//client
		else{
			errorCode = recv(
				self.fd,
				data,
				length,
				Int32(0) //flags
			)
		}

		//errors
		if errorCode != length {
			print("RUNTIME ERROR > network.swift : Network.receiveFrom() : Error receiving data [\(errorCode)].")
		}
	}
}
