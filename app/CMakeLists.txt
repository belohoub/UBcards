### Application binary

include_directories(
  /usr/include/zbar
)

set(ubcards_SRCS
  main.cpp
  qrcodereader.cpp
  qrcodegenerator.cpp
  qrcodeimageprovider.cpp
  historymodel.cpp
  filehelper.cpp
  cardstorage.cpp
  cardstoragemodel.cpp
)

add_executable(ubcards ${ubcards_SRCS})
qt5_use_modules(ubcards Gui Quick Qml)
target_link_libraries(ubcards -lzbar -lqrencode)
install(TARGETS ubcards RUNTIME DESTINATION ".")

add_subdirectory(qml)
if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
add_custom_target(ubcards-qmlfiles ALL
    COMMAND cp -r ${CMAKE_CURRENT_SOURCE_DIR}/qml ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${QMLFILES}
)
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")


