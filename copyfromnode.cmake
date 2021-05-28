# cmake -P copyfromnode.cmake
set(NODE_VER 14.17.0)
set(NODE_DIR ${CMAKE_CURRENT_LIST_DIR}/../nodejs_${NODE_VER}_repo/deps/openssl/config)
if(NOT EXISTS ${NODE_DIR})
  message(FATAL_ERROR "directory ${NODE_DIR} does not exist: update NODE_VER (${NODE_VER})?")
endif()
foreach(d
  archs/linux-x86_64/*.s
  archs/VC-WIN64A/*.asm
  )
  file(GLOB_RECURSE files RELATIVE ${NODE_DIR} ${NODE_DIR}/${d})
  foreach(f ${files})
    execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${NODE_DIR}/${f} ${f}
      WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
      )
  endforeach()
endforeach()
