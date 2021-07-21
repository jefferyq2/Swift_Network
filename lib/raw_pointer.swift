/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Raw Pointers [0.1.0] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                 Raw Pointers by I.A.

        Raw Pointers is an utility program that allows you to use collections of
    bytes (considered as UInt8) easilly in Swift.

    17/04/2021 > [0.1.0] :
    - Created raw_pointer.swift.
	- Added some useful String conversion methods.

    BUGS : .
    NOTES : .

    Contact     : i.a.sebsil83@gmail.com
    Youtube     : https://www.youtube.com/user/IAsebsil83
    GitHub repo : https://github.com/iasebsil83

    Let's Code !                                  By I.A.
*********************************************************************************
    LICENCE :
    Swift_RawPointer
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




















// -------------------------------- BASICS --------------------------------

//class
class RawPointer {

	//attributes
	var length : Int
	var ptr    : UnsafeMutableRawPointer



	//init
	init(_ length:Int) {

		//set length
		self.length = length

		//allocation
		let ptrLyo = MemoryLayout<UInt8>.stride * length
		self.ptr   = UnsafeMutableRawPointer.allocate(
			byteCount: ptrLyo,
			alignment: MemoryLayout<UInt8>.alignment
		)

		//reset pointer
		for i in 0..<length {
			self.ptr.advanced(
				by: i * MemoryLayout<UInt8>.stride
			).storeBytes(
				of: UInt8(0),
				as: UInt8.self
			)
		}
	}

	init(_ str:String) {

		//set length
		self.length = str.count

		//create pointer
		let ptrLyo = MemoryLayout<UInt8>.stride * str.count
		self.ptr   = UnsafeMutableRawPointer.allocate(
			byteCount: ptrLyo,
			alignment: MemoryLayout<UInt8>.alignment
		)

		//create utf8 UInt8 array
		let uint8Arr : [UInt8] = Array(str.utf8)

		//fill pointer
		for i in 0..<str.count {
			self.ptr.advanced(
				by: i * MemoryLayout<UInt8>.stride
			).storeBytes(
				of: UInt8(uint8Arr[i]),
				as: UInt8.self
			)
		}
	}



	//get - set
	func _get(_ idx:Int) -> UInt8 {

		//error case
		if idx >= self.length {
			print("RUNTIME ERROR > raw_pointer.swift : RawPointer.get() : Index is out of range.")
			return UInt8(0)
		}

		//get concerned element
		return self.ptr.advanced(
			by: idx * MemoryLayout<UInt8>.stride
		).load(
			as: UInt8.self
		)
	}

	func _set(_ idx:Int, _ value:UInt8) {

		//error case
		if idx >= self.length {
			print("RUNTIME ERROR > raw_pointer.swift : RawPointer.get() : Index is out of range.")
			return
		}

		//set concerned element
		self.ptr.advanced(
			by: idx * MemoryLayout<UInt8>.stride
		).storeBytes(
			of: value,
			as: UInt8.self
		)
	}



	//reset - free
	func reset() {
		for i in 0..<self.length {
			self._set(i, UInt8(0))
		}
	}

	func free() {
		self.ptr.deallocate()
	}



	//string <-> raw pointer conversions
	func toString() -> String {

		//create a character array
		var charArr = [Character]()

		//fill it with the content of the raw pointer
		for i in 0..<self.length {
			charArr.append(
				Character(Unicode.Scalar( self._get(i) ))
			)
		}

		//make string from character array
		return String(charArr)
	}

	func setString(_ str:String) {

		//create utf8 UInt8 array
		let uint8Arr : [UInt8] = Array(str.utf8)

		//reset pointer data
		self.reset()

		//fill pointer with string data
		for i in 0..<str.count {
			self.ptr.advanced(
				by: i * MemoryLayout<UInt8>.stride
			).storeBytes(
				of: UInt8(uint8Arr[i]),
				as: UInt8.self
			)
		}
	}

	func compare(_ str:String, _ length:Int) -> Bool {

		//create a utf8 UInt8 array
		let uint8Arr : [UInt8] = Array(str.utf8)

		//for each character
		for i in 0..<length {

			//compare UInt8 values
			if self._get(i) != uint8Arr[i] {
				return false
			}
		}

		return true
	}
}

