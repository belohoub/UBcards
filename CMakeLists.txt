project(tagger C CXX)
cmake_minimum_required(VERSION 2.8.9)

find_program(INTLTOOL_MERGE intltool-merge)
if(NOT INTLTOOL_MERGE)
    message(FATAL_ERROR "Could not find intltool-merge, please install the intltool package")
endif()
find_program(INTLTOOL_EXTRACT intltool-extract)
if(NOT INTLTOOL_EXTRACT)
    message(FATAL_ERROR "Could not find intltool-extract, please install the intltool package")
endif()

#do not remove this line, its required for the correct functionality of the Ubuntu-SDK
set(UBUNTU_MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Tells QtCreator location and name of the manifest file")
set (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

find_package(Qt5Core)
find_package(Qt5Qml)
find_package(Qt5Quick)
#find_package(ubuntu-sdk-libs)

#automatically create moc files
set(CMAKE_AUTOMOC ON)

# components PATH
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")

set(APP_NAME          tagger)

#set install paths
set(CMAKE_INSTALL_PREFIX /)
set(DATA_DIR .)
set(DESKTOP_DIR ${DATA_DIR})

#This command figures out the target architecture and puts it into the manifest file
execute_process(
  COMMAND dpkg-architecture -qDEB_HOST_ARCH
  OUTPUT_VARIABLE CLICK_ARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

execute_process(
  COMMAND cp
  #/usr/lib/libzbar.so.0 # for 15.04
  /usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/libzbar.so.0
  /usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/libqrencode.so
  /usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/libqrencode.so.3
  #/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/libqrencode.so.3.4.3
  ${CMAKE_BINARY_DIR}
)

configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json
        DESTINATION ${CMAKE_INSTALL_PREFIX})

set(DESKTOP_FILE "tagger.desktop")

file(GLOB_RECURSE I18N_SRC_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/po
    *.qml *.js *.cpp *.h)
list(APPEND I18N_SRC_FILES ${DESKTOP_FILE}.in.in.h)
list(SORT I18N_SRC_FILES)

configure_file(${DESKTOP_FILE}.in.in ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}.in)
add_custom_target(${DESKTOP_FILE} ALL
    COMMENT "Merging translations into ${DESKTOP_FILE}"
    COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} > /dev/null
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE} DESTINATION ${DESKTOP_DIR})
install(DIRECTORY "app/graphics" DESTINATION ${DATA_DIR})
install(FILES "tagger.apparmor" DESTINATION ${DATA_DIR})
install(FILES "tagger-contenthub.json" DESTINATION ${DATA_DIR})
install(FILES
  "${CMAKE_BINARY_DIR}/libzbar.so.0"
  "${CMAKE_BINARY_DIR}/libqrencode.so"
  "${CMAKE_BINARY_DIR}/libqrencode.so.3"
  #"${CMAKE_BINARY_DIR}/libqrencode.so.3.4.3"
DESTINATION lib/${ARCH_TRIPLET})

add_subdirectory(app)
add_subdirectory(po)

#no op custom target for all not compiled files, so they show up in the QtCreator project tree
add_custom_target("tagger_ClickFiles" ALL SOURCES "tagger.apparmor" "manifest.json.in" "tagger-contenthub.json")

