project (
    'github.aeldemery.gtk4_opengl_transition',
    'c', 'vala',
    version: '0.1.0',
)

add_project_arguments([
    '--vapidir', join_paths(meson.current_source_dir(), 'source'/'vapi'),
    # '--pkg', 'gl',
    '--pkg', 'epoxy',
    # '--save-temps',
    ],
    language: 'vala'
)

cc = meson.get_compiler ('c')

subdir ('source' / 'lib',)
subdir ('data' / 'resources',)
subdir ('source',)
