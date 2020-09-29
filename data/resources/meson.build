gnome = import ('gnome')

project_resources = gnome.compile_resources (
    meson.project_name (),
    files ( meson.project_name() + '.gresource.xml' ),
    source_dir: '.',
    c_name: 'project_resources',
)