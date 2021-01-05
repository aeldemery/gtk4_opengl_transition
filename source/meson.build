sources = files (
    'Main.vala',
    'MainWindow.vala',
    'widgets' / 'RippleBin.vala',
    'widgets' / 'TransitionStack.vala',
)

sources += project_resources

dependencies = [
    dependency ('gobject-2.0'),
    dependency ('glib-2.0'),
    dependency ('gtk4', version: '>= 4.0.0'),
    cc.find_library ('m', required: false),
    dependency ('epoxy'),
    shader_dep,
]

executable (
    meson.project_name (),
    sources: sources,
    dependencies: dependencies,
    install: true,
)