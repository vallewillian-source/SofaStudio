C
➜  sofa-studio git:(main) ✗ cd "/Users/vallewillian/www/sofa-studio/." && /bin/bash -lc 'cd /Users/vallewillian/www/sofa-studio && ./RUN.sh'
==> Configurando CMake...
-- Could NOT find WrapVulkanHeaders (missing: Vulkan_INCLUDE_DIR) 
-- Could NOT find WrapVulkanHeaders (missing: Vulkan_INCLUDE_DIR) 
CMake Warning at /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:1626 (message):
  The SofaUI target is a QML module with target path sofa/ui.  It uses an
  OUTPUT_DIRECTORY of /Users/vallewillian/www/sofa-studio/build/src/ui, which
  should end in the same target path, but doesn't.  Tooling such as qmllint
  may not work correctly.
Call Stack (most recent call first):
  /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:3614 (_qt_internal_target_enable_qmllint)
  /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:960 (qt6_target_qml_sources)
  /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:1418 (qt6_add_qml_module)
  src/ui/CMakeLists.txt:13 (qt_add_qml_module)


CMake Warning at /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:285 (message):
  The Sql target is mentioned as a dependency for SofaCore, but not declared.
  The linking might be incomplete.
Call Stack (most recent call first):
  /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:249 (__qt_internal_walk_libs)
  /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:337 (__qt_internal_walk_libs)
  /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:5351 (__qt_internal_collect_all_target_dependencies)
  /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:2966:EVAL:1 (_qt_internal_add_static_qml_plugin_dependencies)
  src/ui/CMakeLists.txt:DEFERRED


CMake Warning at /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:285 (message):
  The Sql target is mentioned as a dependency for SofaCore, but not declared.
  The linking might be incomplete.
Call Stack (most recent call first):
  /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:249 (__qt_internal_walk_libs)
  /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:337 (__qt_internal_walk_libs)
  /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:5351 (__qt_internal_collect_all_target_dependencies)
  /opt/homebrew/lib/cmake/Qt6Qml/Qt6QmlMacros.cmake:2966:EVAL:1 (_qt_internal_add_static_qml_plugin_dependencies)
  src/ui/CMakeLists.txt:DEFERRED


CMake Warning at /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:285 (message):
  The Sql target is mentioned as a dependency for SofaAddonPostgres, but not
  declared.  The linking might be incomplete.
Call Stack (most recent call first):
  /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:337 (__qt_internal_walk_libs)
  /opt/homebrew/lib/cmake/Qt6Core/Qt6CoreMacros.cmake:772 (__qt_internal_collect_all_target_dependencies)
  /opt/homebrew/lib/cmake/Qt6Core/Qt6CoreMacros.cmake:877 (_qt_internal_finalize_executable)
  /opt/homebrew/lib/cmake/Qt6Core/Qt6CoreMacros.cmake:846:EVAL:1 (qt6_finalize_target)
  apps/desktop/CMakeLists.txt:DEFERRED


CMake Warning at /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:285 (message):
  The Sql target is mentioned as a dependency for SofaAddonPostgres, but not
  declared.  The linking might be incomplete.
Call Stack (most recent call first):
  /opt/homebrew/lib/cmake/Qt6/QtPublicWalkLibsHelpers.cmake:337 (__qt_internal_walk_libs)
  /opt/homebrew/lib/cmake/Qt6Core/Qt6CoreMacros.cmake:772 (__qt_internal_collect_all_target_dependencies)
  /opt/homebrew/lib/cmake/Qt6Core/Qt6CoreMacros.cmake:877 (_qt_internal_finalize_executable)
  /opt/homebrew/lib/cmake/Qt6Core/Qt6CoreMacros.cmake:846:EVAL:1 (qt6_finalize_target)
  apps/desktop/CMakeLists.txt:DEFERRED


-- Configuring done (1.3s)
-- Generating done (0.2s)
-- Build files have been written to: /Users/vallewillian/www/sofa-studio/build
==> Compilando (jobs=8)...
[  0%] Automatic MOC for target SofaUIplugin
[  0%] Automatic MOC for target SofaCore
[  0%] Built target generate_qmlls_build_ini_file
[  2%] Built target SofaUI_copy_res
[  2%] Built target SofaUI_copy_qml
[  3%] Automatic MOC for target SofaUIplugin_init
[  4%] Built target SofaUI_resources_2
[  5%] Built target SofaUI_resources_3
[  6%] Built target SofaUI_resources_1
[  6%] Built target SofaUIplugin_autogen
[  6%] Built target SofaCore_autogen
[  7%] Built target sofa-desktop_qmlimportscan
[  8%] Built target sofa-desktop_copy_qml
[  8%] Built target SofaUIplugin_init_autogen
[  9%] Built target sofa-desktop_copy_res
[ 10%] Running AUTOMOC file extraction for target SofaCore
[ 11%] Running AUTOMOC file extraction for target SofaUIplugin_init
[ 11%] Built target SofaCore_automoc_json_extraction
[ 11%] Built target SofaUIplugin_init_automoc_json_extraction
[ 13%] Running moc --collect-json for target SofaCore
[ 16%] Built target SofaUIplugin_init
[ 26%] Built target SofaCore
[ 28%] Automatic MOC for target SofaDataGrid
[ 28%] Automatic MOC for target SofaUI
[ 29%] Built target SofaUI_autogen
[ 29%] Built target SofaAddonPostgres
[ 29%] Built target SofaDataGrid_autogen
[ 30%] Running AUTOMOC file extraction for target SofaUI
[ 31%] Running AUTOMOC file extraction for target SofaDataGrid
[ 31%] Built target SofaUI_automoc_json_extraction
[ 31%] Built target SofaDataGrid_automoc_json_extraction
[ 32%] Running moc --collect-json for target SofaDataGrid
[ 36%] Built target SofaDataGrid
[ 79%] Built target SofaUI
[ 82%] Built target SofaUIplugin
[ 83%] Automatic MOC and UIC for target sofa-desktop
[ 83%] Built target sofa-desktop_autogen
[ 83%] Running AUTOMOC file extraction for target sofa-desktop
[ 83%] Built target sofa-desktop_automoc_json_extraction
[100%] Built target sofa-desktop
==> Executando: /Users/vallewillian/www/sofa-studio/build/apps/desktop/SofaStudio.app/Contents/MacOS/SofaStudio
Sofa DataGrid Module Initialized
[INFO] "LocalStore DB path: /Users/vallewillian/Library/Application Support/SofaStudio/sofa.db"
[INFO] "Registered addon: postgres (PostgreSQL)"
[INFO] "Command registered: test.hello"
[INFO] "LocalStore initialized successfully"
qml: Loader type changed: 0 home
qml: 🧭 Loader index=0 type=home schema=public table=
qml: 🥞 StackLayout index=0
qt.qpa.fonts: Populating font family aliases took 59 ms. Replace uses of missing font family "Monospace" with one that exists to avoid this cost. 
[INFO] "Opened connection: SofaCoding"
qml: Loader type changed: 1 table
qml: 🧭 Loader index=1 type=table schema=pg_catalog table=pg_authid
qml: 📥 Buscando dados pg_catalog.pg_authid
qml: Loader type changed: 2 table
qml: 🧭 Loader index=2 type=table schema=notes table=note
qml: 🥞 StackLayout index=2
🔎 PG query: "SELECT * FROM \"pg_catalog\".\"pg_authid\" LIMIT 101 OFFSET 0"
🧪 PG row 0 cols: 12 "QString(valid):6171 len=4 | QString(valid):pg_database_owner len=17 | bool(valid):false | bool(valid):true | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | int(valid):-1 | QString(null):NULL len=0 | QDateTime(null):NULL"
🧪 PG row 1 cols: 12 "QString(valid):6181 len=4 | QString(valid):pg_read_all_data len=16 | bool(valid):false | bool(valid):true | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | int(valid):-1 | QString(null):NULL len=0 | QDateTime(null):NULL"
🧪 PG row 2 cols: 12 "QString(valid):6182 len=4 | QString(valid):pg_write_all_data len=17 | bool(valid):false | bool(valid):true | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | int(valid):-1 | QString(null):NULL len=0 | QDateTime(null):NULL"
✅ PG colunas: 12 linhas: 13 ms: 312
qml: ✅ Dataset recebido colunas=12 linhas=13
📏 DataGrid Layout Cols: 12 TotalWidth: 1290
🧪 DataGrid rows payload total: 13
🧪 DataGrid row 0 cols: 12 "QString(valid):6171 len=4 | QString(valid):pg_database_owner len=17 | bool(valid):false | bool(valid):true | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | int(valid):-1 | (null):NULL | (null):NULL"
🧪 DataGrid row 1 cols: 12 "QString(valid):6181 len=4 | QString(valid):pg_read_all_data len=16 | bool(valid):false | bool(valid):true | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | int(valid):-1 | (null):NULL | (null):NULL"
🧪 DataGrid row 2 cols: 12 "QString(valid):6182 len=4 | QString(valid):pg_write_all_data len=17 | bool(valid):false | bool(valid):true | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | bool(valid):false | int(valid):-1 | (null):NULL | (null):NULL"
✅ DataGrid colunas: 12 linhas: 13 rowsStored: 13
qml: 📥 Buscando dados notes.note
🔎 PG query: "SELECT * FROM \"notes\".\"note\" LIMIT 101 OFFSET 0"
🧪 PG row 0 cols: 8 "qulonglong(valid):2 | qulonglong(valid):2 | QString(null):NULL len=0 | QString(valid):Teste len=5 | QString(valid):APP len=3 | QString(null):NULL len=0 | QDateTime(valid):2025-11-20T14:16:57.000Z | QDateTime(valid):2025-11-20T14:16:57.000Z"
🧪 PG row 1 cols: 8 "qulonglong(valid):4 | qulonglong(valid):2 | QString(valid):Título len=6 | QString(valid):Teste 2 len=7 | QString(valid):APP len=3 | QString(null):NULL len=0 | QDateTime(valid):2025-11-20T14:49:37.551Z | QDateTime(valid):2025-12-14T16:19:15.892Z"
🧪 PG row 2 cols: 8 "qulonglong(valid):5 | qulonglong(valid):13 | QString(null):NULL len=0 | QString(valid):Teste len=5 | QString(valid):APP len=3 | QString(null):NULL len=0 | QDateTime(valid):2025-12-21T14:50:16.799Z | QDateTime(valid):2025-12-21T14:50:16.799Z"
✅ PG colunas: 8 linhas: 5 ms: 307
qml: ✅ Dataset recebido colunas=8 linhas=5
📏 DataGrid Layout Cols: 8 TotalWidth: 1200
🧪 DataGrid rows payload total: 5
🧪 DataGrid row 0 cols: 8 "double(valid):2 | double(valid):2 | (null):NULL | QString(valid):Teste len=5 | QString(valid):APP len=3 | (null):NULL | QDateTime(valid):2025-11-20T11:16:57.000 | QDateTime(valid):2025-11-20T11:16:57.000"
🧪 DataGrid row 1 cols: 8 "double(valid):4 | double(valid):2 | QString(valid):Título len=6 | QString(valid):Teste 2 len=7 | QString(valid):APP len=3 | (null):NULL | QDateTime(valid):2025-11-20T11:49:37.551 | QDateTime(valid):2025-12-14T13:19:15.892"
🧪 DataGrid row 2 cols: 8 "double(valid):5 | double(valid):13 | (null):NULL | QString(valid):Teste len=5 | QString(valid):APP len=3 | (null):NULL | QDateTime(valid):2025-12-21T11:50:16.799 | QDateTime(valid):2025-12-21T11:50:16.799"
✅ DataGrid colunas: 8 linhas: 5 rowsStored: 5
qml: 🥞 StackLayout index=1
qml: 🥞 StackLayout index=2
qml: 🥞 StackLayout index=1
qt.qml.context: qrc:/qt/qml/sofa/ui/AppTabs.qml:272:25 Parameter "mouse" is not declared. Injection of parameters into signal handlers is deprecated. Use JavaScript functions with formal parameters instead.
qml: 🥞 StackLayout index=2
➜  sofa-studio git:(main) ✗ 