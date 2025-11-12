# Function to extract OpenSSL version from opensslv.h
function(extractOpensslVersion opensslv_h version_var)
  file(STRINGS ${opensslv_h} version_line
   REGEX "^#[ ]*define[ ]+OPENSSL_VERSION_TEXT"
   LIMIT_COUNT 1
   )
  if(version_line MATCHES "OPENSSL_VERSION_TEXT[ \t]+\"([^\"]+)\"")
    set(${version_var} ${CMAKE_MATCH_1} PARENT_SCOPE)
  else()
    message(FATAL_ERROR "Failed to extract OpenSSL version from ${opensslv_h}")
  endif()
endfunction()
set(opensslRootDir ${CMAKE_CURRENT_LIST_DIR}/..)
set(opensslVerFile include/openssl/opensslv.h)
set(mainOpensslHeader ${opensslRootDir}/${opensslVerFile})
set(nodeOpensslDir ${node_SOURCE_DIR}/deps/openssl)
set(nodeOpensslHeader ${nodeOpensslDir}/openssl/${opensslVerFile})
set(nodeAsmDir ${nodeOpensslDir}/config)
if(NOT EXISTS ${nodeOpensslHeader})
  message(FATAL_ERROR "Node.js OpenSSL header not found at: ${nodeOpensslHeader}")
endif()
extractOpensslVersion(${mainOpensslHeader} mainOpensslVersion)
extractOpensslVersion(${nodeOpensslHeader} nodeOpensslVersion)
if(NOT "${mainOpensslVersion}" STREQUAL "${nodeOpensslVersion}")
  message(FATAL_ERROR
    "OpenSSL version mismatch!\n"
    "Main OpenSSL version: ${mainOpensslVersion}\n"
    "Node.js OpenSSL version: ${nodeOpensslVersion}\n"
    "Versions must match to ensure compatibility.")
else()
  message(STATUS "OpenSSL versions match: ${mainOpensslVersion}")
endif()
if(NOT EXISTS ${nodeAsmDir})
  message(FATAL_ERROR "directory ${nodeAsmDir} does not exist: update node repo?")
endif()
if(NOT WIN32)
  # git checkout of node repo on windows may have CRLF line endings
  # and copy_if_different will cause an unwanted dirty repo
  # NOTE: I don't develop on Windows, so this catch to update the
  # opensslasm repo will happen as I update the openssl and node
  # repos to newer releases on an OS where I do develop
  foreach(d
    archs/darwin64-arm64-cc/*.s
    archs/linux-aarch64/*.s
    archs/linux-x86_64/*.s
    )
    file(GLOB_RECURSE files RELATIVE ${nodeAsmDir} ${nodeAsmDir}/${d})
    foreach(f ${files})
      execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${nodeAsmDir}/${f} ${f}
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        )
    endforeach()
  endforeach()
endif()
