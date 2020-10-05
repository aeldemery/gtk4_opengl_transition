sources = files (
    'Main.vala',
    'MainWindow.vala',
    'widgets' / 'RippleBin.vala',
    'widgets' / 'TransitionStack.vala',
)

sources += project_resources

sources += lib_sources

dependencies = [
    dependency ('gobject-2.0'),
    dependency ('glib-2.0'),
    dependency ('gtk4'),
    cc.find_library ('m', required: false),
    dependency ('epoxy'),
    #shader_dep,
]

executable (
    meson.project_name (),
    sources: sources,
    dependencies: dependencies,
    install: true,
)