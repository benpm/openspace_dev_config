# Optionally disable the use of vcpkg for Windows builds
set(DISABLE_VCPKG ON CACHE BOOL "Disable the use of vcpkg libs for Windows builds")
if (WIN32 AND DISABLE_VCPKG)
  # This works for all subprojects due to MSBuild's hierarchical search
  configure_file(
    "${CMAKE_SOURCE_DIR}/support/cmake/Directory.Build.Props.template"
    "${CMAKE_BINARY_DIR}/Directory.Build.props"
    COPYONLY
  )
endif ()