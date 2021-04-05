#=============================================================================
# SPDX-FileCopyrightText: 2021 Johnny Jazeix <jazeix@gmail.com>
#
# SPDX-License-Identifier: BSD-3-Clause
#=============================================================================

set(QTQUICKCALENDAR_MODULE "auto" CACHE STRING "Policy for qtquickcalendar module [auto|submodule|system|disabled]")

if(NOT ${QTQUICKCALENDAR_MODULE} STREQUAL "disabled")
  include(qt_helper)

  getQtQmlPath(_qt_qml_system_path)
  set(_calendar_system_dir "${_qt_qml_system_path}/QtQuick/Calendar")

  if(${QTQUICKCALENDAR_MODULE} STREQUAL "submodule")
    message(STATUS "Building qtquickcalendar module from submodule")
    set(_need_calendar_submodule "TRUE")
  else()
    # try to find module in system scope
    find_library(QTQUICKCALENDAR_LIBRARY NAMES libqtquickcalendarplugin PATHS ${_calendar_system_dir} NO_DEFAULT_PATH)
    # Look in default path if not found
    if(NOT QTQUICKCALENDAR_LIBRARY AND NOT "${CMAKE_FIND_ROOT_PATH}" STREQUAL "")
      # Remove the root path to look for the library
      set(_calendar_without_cmake_find_root_path)
      string(REPLACE "${CMAKE_FIND_ROOT_PATH}" "" _calendar_without_cmake_find_root_path ${_calendar_system_dir})
      find_library(QTQUICKCALENDAR_LIBRARY NAMES libqtquickcalendarplugin PATHS ${_calendar_without_cmake_find_root_path})
    endif()

    if(QTQUICKCALENDAR_LIBRARY)
      message(STATUS "Using system qtquickcalendar plugin at ${QTQUICKCALENDAR_LIBRARY}")
      # for packaging builds, copy the module manually to the correct location
      if(SAILFISHOS)
        file(COPY ${_calendar_system_dir}/qmldir ${QTQUICKCALENDAR_LIBRARY} DESTINATION share/harbour-gcompris-qt/lib/qml/QtQuick/Calendar)
      elseif(ANDROID)
        file(COPY ${_calendar_system_dir}/qmldir ${QTQUICKCALENDAR_LIBRARY} DESTINATION lib/qml/QtQuick/Calendar)
      endif()
      # FIXME: add others as needed
    else()
      if(${QTQUICKCALENDAR_MODULE} STREQUAL "auto")
        message(STATUS "Did not find the qtquickcalendar module in system scope, falling back to submodule build ...")
        set(_need_calendar_submodule "TRUE")
      else()
        message(FATAL_ERROR "Did not find the qtquickcalendar module in system scope and submodule build was not requested. Can't continue!")
      endif()
    endif()
  endif()

  if(_need_calendar_submodule)
    # build qtquickcalendar ourselves from submodule
    include(ExternalProject)
    if(UBUNTU_TOUCH)
        unset(QT_QMAKE_EXECUTABLE CACHE)
        find_program(_qmake_program "qmake")
    else()
        get_property(_qmake_program TARGET Qt5::qmake PROPERTY IMPORT_LOCATION)
    endif()
    set(_calendar_source_dir ${CMAKE_SOURCE_DIR}/external/qtquickcalendar)
    if(WIN32)
      set(_calendar_library_dir "release/")
      set(_calendar_library_file "qtquickcalendarplugin.dll")
    elseif(CMAKE_HOST_APPLE)
      set(_calendar_library_dir "")
      set(_calendar_library_file "libqtquickcalendarplugin.dylib")
    else()
      set(_calendar_library_dir "qml/QtQuick/Calendar/")
      set(_calendar_library_file "libqtquickcalendarplugin.so")
    endif()
    set(_calendar_install_dir ${CMAKE_BINARY_DIR}/lib/qml/QtQuick/Calendar)
    # make sure submodule is up2date
    find_package(Git)
    if(GIT_FOUND)
      execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    endif()

    # for visual studio, we need to create a vcxproj
    if(WIN32 AND NOT MINGW)
      set(_qmake_options -spec win32-msvc -tp vc)
    else()
      set(_qmake_options "")
    endif()
    # Ninja is not supported by qmake.
    # In case Ninja is set as generator, use make on Linux, nmake on Windows
    if(${CMAKE_GENERATOR} MATCHES "Ninja")
      if(WIN32)
        set(QMAKE_MAKE_PROGRAM "nmake")
      else()
        set(QMAKE_MAKE_PROGRAM "make")
      endif()
    endif()
    ExternalProject_Add(qtquick_calendar_project
      DOWNLOAD_COMMAND ""
      SOURCE_DIR ${_calendar_source_dir}
      CONFIGURE_COMMAND ${_qmake_program} ${_qmake_options} ${_calendar_source_dir}/qtquickcalendar.pro
      BUILD_COMMAND ${QMAKE_MAKE_PROGRAM}
      PATCH_COMMAND ${GIT_EXECUTABLE} apply ${CMAKE_SOURCE_DIR}/cmake/patch_Qt512_to_Qt57.diff
      INSTALL_DIR ${_calendar_install_dir}
      # TODO install the .qml instead of qmlc?
      INSTALL_COMMAND ${CMAKE_COMMAND} -E copy ${_calendar_library_dir}${_calendar_library_file} ${_calendar_library_dir}/qmldir ${_calendar_library_dir}/DayOfWeekRow.qmlc ${_calendar_library_dir}/MonthGrid.qmlc ${_calendar_library_dir}/WeekNumberColumn.qmlc ${_calendar_install_dir}
      )

    add_library(qtquickcalendar SHARED IMPORTED)
    set_target_properties(qtquickcalendar PROPERTIES IMPORTED_LOCATION ${_calendar_install_dir}/${_calendar_library_file})

    if(SAILFISHOS)
      install(DIRECTORY ${_calendar_install_dir} DESTINATION share/harbour-gcompris-qt/lib/qml/QtQuick)
    elseif(APPLE)
      install(DIRECTORY ${_calendar_install_dir} DESTINATION gcompris-qt.app/Contents/lib/qml/QtQuick)
    else()
      install(DIRECTORY ${_calendar_install_dir} DESTINATION lib/qml/QtQuick)
    endif()
  endif()
endif()
