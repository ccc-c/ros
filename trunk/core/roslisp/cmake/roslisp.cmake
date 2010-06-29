rosbuild_find_ros_package(genmsg_cpp)

# Message-generation support.
macro(genmsg_lisp)
  rosbuild_get_msgs(_msglist)
  set(_autogen "")
  foreach(_msg ${_msglist})
    # Construct the path to the .msg file
    set(_input ${PROJECT_SOURCE_DIR}/msg/${_msg})
  
    rosbuild_gendeps(${PROJECT_NAME} ${_msg})
  
    set(genmsg_lisp_exe ${genmsg_cpp_PACKAGE_PATH}/genmsg_lisp)
  
    set(_output_lisp ${PROJECT_SOURCE_DIR}/msg/lisp/${PROJECT_NAME}/${_msg})
    set(_output_lisp_package ${PROJECT_SOURCE_DIR}/msg/lisp/${PROJECT_NAME}/_package.lisp)
    set(_output_lisp_export ${PROJECT_SOURCE_DIR}/msg/lisp/${PROJECT_NAME}/_package_${_msg})
    string(REPLACE ".msg" ".lisp" _output_lisp ${_output_lisp})
    string(REPLACE ".msg" ".lisp" _output_lisp_export ${_output_lisp_export})
  
    # Add the rule to build the .h and .py from the .msg
    add_custom_command(OUTPUT ${_output_lisp} ${_output_lisp_package} ${_output_lisp_export}
                       COMMAND ${genmsg_lisp_exe} ${_input}
                       DEPENDS ${_input} ${genmsg_lisp_exe} ${gendeps_exe} ${${PROJECT_NAME}_${_msg}_GENDEPS} ${ROS_MANIFEST_LIST})
    list(APPEND _autogen ${_output_lisp} ${_output_lisp_package} ${_output_lisp_export})
  endforeach(_msg)
  # Create a target that depends on the union of all the autogenerated
  # files
  add_custom_target(ROSBUILD_genmsg_lisp DEPENDS ${_autogen})
  # Make our target depend on rosbuild_premsgsrvgen, to allow any
  # pre-msg/srv generation steps to be done first.
  add_dependencies(ROSBUILD_genmsg_lisp rosbuild_premsgsrvgen)
  # Add our target to the top-level genmsg target, which will be fired if
  # the user calls genmsg()
  add_dependencies(rospack_genmsg ROSBUILD_genmsg_lisp)
endmacro(genmsg_lisp)

# Call the macro we just defined.
genmsg_lisp()

# Service-generation support.
macro(gensrv_lisp)
  rosbuild_get_srvs(_srvlist)
  set(_autogen "")
  foreach(_srv ${_srvlist})
    # Construct the path to the .srv file
    set(_input ${PROJECT_SOURCE_DIR}/srv/${_srv})
  
    rosbuild_gendeps(${PROJECT_NAME} ${_srv})
  
    set(gensrv_lisp_exe ${genmsg_cpp_PACKAGE_PATH}/gensrv_lisp)

    set(_output_lisp ${PROJECT_SOURCE_DIR}/srv/lisp/${PROJECT_NAME}/${_srv})
    set(_output_lisp_package ${PROJECT_SOURCE_DIR}/srv/lisp/${PROJECT_NAME}/_package.lisp)
    set(_output_lisp_export ${PROJECT_SOURCE_DIR}/srv/lisp/${PROJECT_NAME}/_package_${_srv})
  
    string(REPLACE ".srv" ".lisp" _output_lisp ${_output_lisp})
    string(REPLACE ".srv" ".lisp" _output_lisp_export ${_output_lisp_export})
  
    # Add the rule to build the .h and .py from the .srv
    add_custom_command(OUTPUT ${_output_lisp} ${_output_lisp_package} ${_output_lisp_export}
                       COMMAND ${gensrv_lisp_exe} ${_input}
                       DEPENDS ${_input} ${gensrv_lisp_exe} ${gendeps_exe} ${${PROJECT_NAME}_${_srv}_GENDEPS} ${ROS_MANIFEST_LIST})
    list(APPEND _autogen ${_output_lisp} ${_output_lisp_package} ${_output_lisp_export})
  endforeach(_srv)
  # Create a target that depends on the union of all the autogenerated
  # files
  add_custom_target(ROSBUILD_gensrv_lisp DEPENDS ${_autogen})
  # Make our target depend on rosbuild_premsgsrvgen, to allow any
  # pre-msg/srv generation steps to be done first.
  add_dependencies(ROSBUILD_gensrv_lisp rosbuild_premsgsrvgen)
  # Add our target to the top-level gensrv target, which will be fired if
  # the user calls gensrv()
  add_dependencies(rospack_gensrv ROSBUILD_gensrv_lisp)
endmacro(gensrv_lisp)


# Call the macro we just defined.
gensrv_lisp()



# Old rospack_add_lisp_executable.
#macro(rospack_add_lisp_executable exe lispfile)
#  add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${exe}
#                     COMMAND ${roslisp_make_node_exe} ${CMAKE_CURRENT_SOURCE_DIR}/${lispfile} ${roslisp_image_file} ${CMAKE_CURRENT_SOURCE_DIR}/${exe}
#                     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${lispfile} ${roslisp_image_file})
#  set(_targetname _roslisp_${exe})
#  string(REPLACE "/" "_" _targetname ${_targetname})
#  add_custom_target(${_targetname} ALL
#                    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${exe})
#  add_dependencies(${_targetname} _rospack_genmsg)
#  add_dependencies(${_targetname} _rospack_gensrv)
#endmacro(rospack_add_lisp_executable)

# New rospack_add_lisp_executable (#1102)
rosbuild_find_ros_package(roslisp)
set(roslisp_make_node_exe ${roslisp_PACKAGE_PATH}/scripts/make_node_exec)

macro(rosbuild_add_lisp_executable _output _system_name _entry_point)
  set(_targetname _roslisp_${_output})
  string(REPLACE "/" "_" _targetname ${_targetname})
  # Add dummy custom command to get make clean behavior right.
  add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${_output} ${CMAKE_CURRENT_SOURCE_DIR}/${_output}.lisp
    COMMAND echo -n)
  add_custom_target(${_targetname} ALL
                     DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${_output} ${CMAKE_CURRENT_SOURCE_DIR}/${_output}.lisp 
                     COMMAND ${roslisp_make_node_exe} ${PROJECT_NAME} ${_system_name} ${_entry_point} ${CMAKE_CURRENT_SOURCE_DIR}/${_output})
  add_dependencies(${_targetname} rosbuild_precompile)
endmacro(rosbuild_add_lisp_executable)

macro(rospack_add_lisp_executable  _output _system_name _entry_point)
  _rosbuild_warn_deprecate_rospack_prefix(rospack_add_lisp_executable)
  rosbuild_add_lisp_executable(${_output} ${_system_name} ${_entry_point})
endmacro(rospack_add_lisp_executable)
