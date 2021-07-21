#executables
run: lib/include_NW.h lib/raw_pointer.swift src/network.swift src/1_server.swift src/2_client.swift again

	@#SERVER

	@#create temporary all-in-one swift source file
	@cat lib/raw_pointer.swift >  run1.swift
	@cat src/network.swift     >> run1.swift
	@cat src/1_server.swift    >> run1.swift

	@#compilation
	@echo "compiling server :"
	@echo "    lib/raw_pointer.swift"
	@echo "    src/network.swift"
	@echo "    src/1_server.swift"
	swiftc run1.swift -import-objc-header lib/include_NW.h



	@#CLIENT

	@#create temporary all-in-one swift source file
	@cat lib/raw_pointer.swift >  run2.swift
	@cat src/network.swift     >> run2.swift
	@cat src/2_client.swift    >> run2.swift

	@#compilation
	@echo "compiling client :"
	@echo "    lib/raw_pointer.swift"
	@echo "    src/network.swift"
	@echo "    src/2_client.swift"
	swiftc run2.swift -import-objc-header lib/include_NW.h



	@#RESET

	@#remove temporary files
	@rm -f run1.swift run2.swift again



#empty file created to relaunch compilation (even if no source file is modified)
again:
	@touch again
