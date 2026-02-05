cmake_minimum_required(VERSION 3.16)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_add_executable(sofa-desktop
    main.cpp
)

set(APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/../../src/ui/assets/Ícone.icns")
set_source_files_properties(${APP_ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
target_sources(sofa-desktop PRIVATE ${APP_ICON})

qt_add_qml_module(sofa-desktop
    URI sofa.studio
    VERSION 1.0
    QML_FILES qml/Main.qml
)

target_link_libraries(sofa-desktop
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE SofaCore
    PRIVATE SofaDataGrid
    PRIVATE SofaUI
    PRIVATE SofaUIplugin
    PRIVATE SofaAddonPostgres
)

set_target_properties(sofa-desktop PROPERTIES OUTPUT_NAME "sofa-studio")
set_target_properties(sofa-desktop PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_ICON_FILE "Ícone.icns"
)
