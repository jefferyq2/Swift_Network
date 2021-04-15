#executables
run: src/include_NW.h network.swift 1_server.swift 2_client.swift again

	@#SERVER

	@#create temporary all-in-one swift source file
	@cat src/raw_pointer.swift >  run1.swift
	@cat network.swift         >> run1.swift
	@cat 1_server.swift        >> run1.swift

	@#compilation
	@echo "compiling server :"
	@echo "    src/raw_pointer.swift"
	@echo "    network.swift"
	@echo "    1_server.swift"
	swiftc run1.swift -import-objc-header src/include_NW.h



	@#CLIENT

	@#create temporary all-in-one swift source file
	@cat src/raw_pointer.swift >  run2.swift
	@cat network.swift         >> run2.swift
	@cat 2_client.swift        >> run2.swift

	@#compilation
	@echo "compiling client :"
	@echo "    src/raw_pointer.swift"
	@echo "    network.swift"
	@echo "    2_client.swift"
	swiftc run2.swift -import-objc-header src/include_NW.h



	@#RESET

	@#remove temporary files
	@rm -f run1.swift run2.swift again



#empty file created to relaunch compilation (even if no source file is modified)
again:
	@touch again
