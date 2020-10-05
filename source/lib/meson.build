lib_sources = files (
    'ShaderBin.vala',
    'ShaderPaintable.vala',
    'ShaderStack.vala',
    'shaderlibrary.vala',
)

lib_inc = include_directories ('.')

lib_dependencies = [
    dependency ('gtk4', version: '>=3.99.2'),
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
]

shader_lib = library (
    'shaderlibrary',
    vala_header: 'shaderlibrary.h',
    vala_vapi: 'shaderlibrary-1.0.vapi',
    include_directories: lib_inc,
    sources: lib_sources,
    dependencies: lib_dependencies,
    install: true,
    install_dir: [true, true, true],
)

shader_dep = declare_dependency (
    include_directories: lib_inc,
    link_with: shader_lib,
)