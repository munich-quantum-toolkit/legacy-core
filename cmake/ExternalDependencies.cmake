# Copyright (c) 2023 - 2026 Chair for Design Automation, TUM
# Copyright (c) 2025 - 2026 Munich Quantum Software Company GmbH
# All rights reserved.
#
# SPDX-License-Identifier: MIT
#
# Licensed under the MIT License

# Declare all external dependencies and make sure that they are available.

include(FetchContent)
include(CMakeDependentOption)
set(FETCH_PACKAGES "")

if(BUILD_MQT_CORE_BINDINGS)
  # Detect the installed nanobind package and import it into CMake
  execute_process(
    COMMAND "${Python_EXECUTABLE}" -m nanobind --cmake_dir OUTPUT_STRIP_TRAILING_WHITESPACE
    OUTPUT_VARIABLE nanobind_ROOT)
  find_package(nanobind CONFIG REQUIRED)
endif()

# renovate: datasource=github-releases depName=nlohmann/json
set(JSON_TAG v3.12.0)
string(REGEX REPLACE "^v" "" JSON_VERSION "${JSON_TAG}")
set(JSON_URL https://github.com/nlohmann/json/releases/download/${JSON_TAG}/json.tar.xz)
set(JSON_SystemInclude ON CACHE INTERNAL "Treat the library headers like system headers")
fetchcontent_declare(nlohmann_json URL ${JSON_URL} FIND_PACKAGE_ARGS ${JSON_VERSION})
list(APPEND FETCH_PACKAGES nlohmann_json)

if(BUILD_MQT_CORE_TESTS)
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
  # Disable the install instructions for GTest, as we do not need them.
  set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
  set(GTEST_VERSION 1.17.0 CACHE STRING "Google Test version")
  # renovate: datasource=github-tags depName=google/googletest
  set(GTEST_REV
      "52eb8108c5bdec04579160ae17225d66034bd723" # tag=v1.17.0
      CACHE STRING "Google Test identifier (tag, branch or commit hash)")
  set(GTEST_URL https://github.com/google/googletest/archive/${GTEST_REV}.tar.gz)
  fetchcontent_declare(googletest URL ${GTEST_URL} FIND_PACKAGE_ARGS ${GTEST_VERSION} NAMES GTest)
  list(APPEND FETCH_PACKAGES googletest)
endif()

set(QDMI_MINIMUM_VERSION 1.4.0 CACHE STRING "Minimum QDMI version")
set(QDMI_VERSION 1.4.0 CACHE STRING "QDMI version")
# renovate: datasource=github-tags depName=Munich-Quantum-Software-Stack/QDMI
set(QDMI_REV
    "6db03d83ad602aaa9fe928b5c3fc5cce84b10061" # tag=v1.4.0
    CACHE STRING "QDMI identifier (tag, branch or commit hash)")
set(QDMI_REPO_OWNER "Munich-Quantum-Software-Stack"
    CACHE STRING "QDMI repository owner (change when using a fork)")
cmake_dependent_option(INSTALL_QDMI "Install QDMI library" ON "MQT_CORE_INSTALL" OFF)
fetchcontent_declare(
  qdmi
  GIT_REPOSITORY https://github.com/${QDMI_REPO_OWNER}/qdmi.git
  GIT_TAG ${QDMI_REV}
  FIND_PACKAGE_ARGS ${QDMI_MINIMUM_VERSION})
list(APPEND FETCH_PACKAGES qdmi)

# Make all declared dependencies available.
fetchcontent_makeavailable(${FETCH_PACKAGES})
