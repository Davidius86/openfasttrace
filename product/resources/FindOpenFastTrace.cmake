include(FindPackageHandleStandardArgs)

if(Java_Runtime_FOUND)
	set(OpenFastTrace_VERSION "${OpenFastTrace_FIND_VERSION_MAJOR}.${OpenFastTrace_FIND_VERSION_MINOR}.${OpenFastTrace_FIND_VERSION_PATCH}")

	# Check whether the found Java version is suitable for specified OpenFastTrace version
	set(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND FALSE)
	if(OpenFastTrace_FIND_VERSION_MAJOR GREATER_EQUAL 4)
		if(Java_VERSION_MAJOR GREATER_EQUAL 17)
			set(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND TRUE)
		endif()
	elseif(OpenFastTrace_FIND_VERSION_MAJOR GREATER_EQUAL 3)
		if(Java_VERSION_MAJOR GREATER_EQUAL 11)
			set(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND TRUE)
		endif()
	else()
		if(Java_VERSION_MAJOR GREATER_EQUAL 8)
			set(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND TRUE)
		endif()
	endif()
	if(NOT OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND)
		set(VERSION_MISMATCH_MESSAGE "")
		if(NOT OpenFastTrace_VERSION VERSION_EQUAL "0.0.0")
			set(VERSION_MISMATCH_MESSAGE " version ${OpenFastTrace_VERSION}")
		endif()
		if(OpenFastTrace_FIND_REQUIRED)
			message(FATAL_ERROR "No suitable Java version found for OpenFastTrace${VERSION_MISMATCH_MESSAGE}.")
		else()
			message(WARNING "No suitable Java version found for OpenFastTrace{VERSION_MISMATCH_MESSAGE}.")
		endif()
	endif()

	list(APPEND OpenFastTrace_FIND_PATH
		${CMAKE_BINARY_DIR}/_deps/openfasttrace
		/usr/share/openfasttrace
	)

	find_file(OpenFastTrace_JAR
		NAMES
			openfasttrace.jar
			openfasttrace-${OpenFastTrace_VERSION}.jar
		PATHS
			${OpenFastTrace_FIND_PATH}
	)
	
	if(OpenFastTrace_VERSION VERSION_EQUAL "0.0.0")
		if(OpenFastTrace_JAR STREQUAL "OpenFastTrace_JAR-NOTFOUND")
			foreach(PATH ${OpenFastTrace_FIND_PATH})
				if(EXISTS "${PATH}")
					file(GLOB OpenFastTrace_NEW_CANDIDATES ${PATH}/openfasttrace-*.jar)
					list(APPEND OpenFastTrace_CANDIDATES ${OpenFastTrace_NEW_CANDIDATES})
				endif()
			endforeach()
			list(LENGTH OpenFastTrace_CANDIDATES OpenFastTrace_CANDIDATES_LENGTH)
			if(OpenFastTrace_CANDIDATES_LENGTH GREATER 0)
				list(POP_FRONT OpenFastTrace_CANDIDATES OpenFastTrace_SELECTED)
				get_filename_component(OpenFastTrace_SELECTED_NAME ${OpenFastTrace_SELECTED} NAME)
				find_file(OpenFastTrace_JAR
					NAMES
						${OpenFastTrace_SELECTED_NAME}
					PATHS
						${OpenFastTrace_FIND_PATH}
				)
				if(NOT OpenFastTrace_JAR STREQUAL "OpenFastTrace_JAR-NOTFOUND")
					string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" OpenFastTrace_VERSION ${OpenFastTrace_SELECTED_NAME})
				endif()
			endif()
		endif()
	endif()

	if(OpenFastTrace_JAR STREQUAL "OpenFastTrace_JAR-NOTFOUND")
		# Set a default OpenFastTrace version depending on found Java version
		if(OpenFastTrace_VERSION VERSION_EQUAL "0.0.0")
			if(Java_VERSION_MAJOR GREATER_EQUAL 17)
				set(OpenFastTrace_VERSION "4.2.0")
				set(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND TRUE)
			elseif(Java_VERSION_MAJOR GREATER_EQUAL 11)
				set(OpenFastTrace_VERSION "3.8.0")
				set(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND TRUE)
			elseif(Java_VERSION_MAJOR GREATER_EQUAL 8)
				set(OpenFastTrace_VERSION "2.3.5")
				set(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND TRUE)
			endif()
		endif()

		if(OpenFastTrace_SUITABLE_JAVA_VERSION_FOUND)
			file(DOWNLOAD
				https://github.com/itsallcode/openfasttrace/releases/download/${OpenFastTrace_VERSION}/openfasttrace-${OpenFastTrace_VERSION}.jar
				${CMAKE_BINARY_DIR}/_deps/openfasttrace/openfasttrace-${OpenFastTrace_VERSION}.jar
			)

			find_file(OpenFastTrace_JAR
				NAMES openfasttrace-${OpenFastTrace_VERSION}.jar
				PATHS
					${CMAKE_BINARY_DIR}/_deps/openfasttrace
			)
		endif()
	endif()

	mark_as_advanced(
		OpenFastTrace_JAR
	)
else()
	if(OpenFastTrace_FIND_REQUIRED)
		message(FATAL_ERROR "No Java found. Required for OpenFastTrace.")
	else()
		message(WARNING "No Java found. Required for OpenFastTrace.")
	endif()
endif()


find_package_handle_standard_args(
	OpenFastTrace
	FOUND_VAR OpenFastTrace_FOUND
	REQUIRED_VARS
		OpenFastTrace_JAR
	VERSION_VAR OpenFastTrace_VERSION
	HANDLE_VERSION_RANGE
)
