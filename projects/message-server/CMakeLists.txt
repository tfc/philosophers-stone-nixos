cmake_minimum_required(VERSION 3.13)

# The project name
project(message-server CXX)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_FLAGS_DEBUG "-g -pthread")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -pthread")

add_compile_options(-Wall -Wextra -pedantic -Werror)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(src)

option(ENABLE_TESTS "Enable tests" ON)
if (${ENABLE_TESTS})
  enable_testing()
  add_subdirectory(test)
endif()

