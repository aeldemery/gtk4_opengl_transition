sources = files (
    'Main.vala',
)

sources += project_resources

dependencies = [
    dependency ('gobject-2.0'),
    dependency ('glib-2.0'),
    dependency ('gtk4'),
    cc.find_library ('m', required: false),
]

executable (
    meson.project_name (),
    sources: sources,
    dependencies: dependencies,
    install: true,
)